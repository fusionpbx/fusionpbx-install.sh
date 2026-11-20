<?php
/*

Upgrade Debian Packages
- Updates the package lists, upgrades packages, repairs dependencies and cleans up.
- Runs non interactive so existing configuration files are kept and no prompt can hang cron.
- Waits for another apt process instead of skipping a scheduled run when they collide.
- Restarts php-fpm and nginx when their package version changes during the upgrade.
- Stops on the first error and exits non zero so cron or monit can report it.
- Uses upgrade instead of dist-upgrade so that no package is ever removed.

Logging goes to syslog with the tag fusionpbx-upgrade. View the log on Debian with:
	journalctl -t fusionpbx-upgrade			all entries, newest last
	journalctl -t fusionpbx-upgrade -n 50		the last 50 lines
	journalctl -t fusionpbx-upgrade --since today	only today
	journalctl -t fusionpbx-upgrade -p err		failures only
	journalctl -t fusionpbx-upgrade -f			follow it while the script runs
	grep fusionpbx-upgrade /var/log/syslog		when rsyslog is installed, this uses journald
The apt output is captured rather than logged so that syslog stays short, one line per step.
Use --debug to log every apt line as well, see those with journalctl -t fusionpbx-upgrade -p debug.

Flags
	--dry-run	simulate everything, change nothing and never restart a service
	--debug	log all apt output to syslog at debug level
A manual run from a terminal also mirrors the messages and the apt output on the screen.

Run manually like this.
/usr/bin/php /usr/src/fusionpbx-install.sh/debian/resources/maintenance/upgrade.php
/usr/bin/php /usr/src/fusionpbx-install.sh/debian/resources/maintenance/upgrade.php --dry-run

Debian, run as root once a week when the system is quiet (crontab -e).
MAILTO=root
30 4 * * 0 /usr/bin/php /usr/src/fusionpbx-install.sh/debian/resources/maintenance/upgrade.php || echo 'package upgrade failed, check journalctl -t fusionpbx-upgrade'

Only run one package updater. Comment out /etc/cron.d/apt-upgrade and any unattended-upgrades
timer first then check what is left with: systemctl list-timers 'apt*'

If the machine can be off or rebooted at the scheduled time, use a one line wrapper script in
/etc/cron.weekly instead so anacron catches up on the next boot.

*/

//only allow running from command line
	if (!defined('STDIN')) {
		exit;
	}

//set the variables
	$dry_run = in_array('--dry-run', $_SERVER['argv'] ?? []);
	$debug = in_array('--debug', $_SERVER['argv'] ?? []);
	$interactive = defined('STDOUT') && function_exists('posix_isatty') && posix_isatty(STDOUT);
	$log_ident = 'fusionpbx-upgrade';
	$lock_file = '/var/lock/fusionpbx-upgrade.lock';
	$min_free_mb = 500; //space needed to download and unpack packages
	$lock_wait = 1800; //seconds to wait for another apt process to finish

//services to restart when their package version changes, in the order they should be restarted
	$services = [
		'php-fpm' => ['pattern' => 'php[0-9]*-fpm', 'unit' => ''], //the unit is the package name, php8.2-fpm
		'nginx' => ['pattern' => 'nginx', 'unit' => 'nginx'], //web server last
	];

//write a message to syslog and mirror it on the console when attached to a terminal
	function log_message($level, $message) {
		global $log_ident, $interactive;
		static $open = false;
		if (!$open) {
			openlog($log_ident, LOG_PID | LOG_CONS, LOG_USER);
			$open = true;
		}
		syslog($level, $message);
		if ($interactive) {
			echo $message."\n";
		}
	}

//stop with an error in syslog, on the console and with a non zero exit code
	function abort($message, $detail = '') {
		if ($detail !== '') {
			$message .= ': '.$detail;
		}
		log_message(LOG_ERR, $message);
		exit(1);
	}

//get the installed versions of a group of packages as an array of package => version
	function package_versions($pattern) {
		$versions = [];
		exec('/usr/bin/dpkg-query -W -f=\'${Package} ${Version}\n\' '.escapeshellarg($pattern).' 2>/dev/null', $lines);
		foreach ($lines as $line) {
			$parts = explode(' ', trim($line), 2);
			if (count($parts) === 2 && !empty($parts[1])) {
				$versions[$parts[0]] = $parts[1];
			}
		}
		return $versions;
	}

//restart a service so it uses the new version, skip it when it is not running
	function restart_service($unit, $reason) {
		exec('/bin/systemctl is-active --quiet '.escapeshellarg($unit).'.service 2>/dev/null', $output, $status);
		if ($status !== 0) {
			log_message(LOG_WARNING, $unit.' is not running, skipped ('.$reason.')');
			return;
		}
		log_message(LOG_NOTICE, 'restarting '.$unit.': '.$reason);
		exec('/bin/systemctl restart '.escapeshellarg($unit.'.service').' 2>&1', $output, $status);
		if ($status !== 0) {
			abort('unable to restart '.$unit.', check systemctl status '.$unit.'.service', implode(' | ', (array) $output));
		}
		log_message(LOG_NOTICE, $unit.' restarted');
	}

//only root can install packages
	if (function_exists('posix_geteuid') && posix_geteuid() !== 0) {
		abort('this script must be run as root');
	}

//stop when the disk is too full to finish an install
	$free_mb = (int) round(disk_free_space('/var') / 1024 / 1024);
	if ($free_mb < $min_free_mb) {
		abort('only '.$free_mb.' MB free on /var, at least '.$min_free_mb.' MB is needed');
	}

//stop if another upgrade is already running, the lock is released when the script exits
	$lock = fopen($lock_file, 'c');
	if ($lock === false || !flock($lock, LOCK_EX | LOCK_NB)) {
		abort('another upgrade is already running');
	}

//wait for another apt process to finish so a scheduled run is not skipped silently
	if (!$dry_run) {
		$waited = 0;
		while (true) {
			//apt knows about every apt and dpkg lock, including the ones this script cannot see
			exec('/usr/bin/apt-get -q check 2>&1', $output, $status);
			$text = implode("\n", (array) $output);
			if ($status === 0) {
				break; //nothing else is using apt
			}
			if (strpos(strtolower($text), 'lock') === false) {
				abort('the package database needs attention', $text);
			}
			if ($waited >= $lock_wait) {
				abort('apt is still busy after '.$waited.' seconds, nothing was changed');
			}
			log_message(LOG_INFO, 'waiting for apt to be free, waited '.$waited.' seconds so far');
			sleep(30);
			$waited = $waited + 30;
		}
	}

//run apt non interactive and keep the local configuration files
	$apt = 'DEBIAN_FRONTEND=noninteractive LANG=C /usr/bin/apt-get -y';
	$apt .= ' -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold';
	$apt .= ' -o Acquire::Retries=3 -o Acquire::http::Timeout=60'; //resilient when nobody is watching
	$simulate = $dry_run ? ' -s' : ''; //simulate the changes, change nothing

//remember the versions before the upgrade so a version change can be detected afterwards
	$before = [];
	foreach ($services as $name => $service) {
		$before[$name] = package_versions($service['pattern']);
	}

//log what ran and how long it took, one line per step keeps syslog readable
	log_message(LOG_INFO, 'upgrade'.($dry_run ? ' dry run' : '').' started on '.gethostname());
	$started = time();

//run the steps in order and stop on the first failure
	$steps = [
		'update package lists' => $apt.' update', //always fetches the lists so the simulation is accurate
		'upgrade packages' => $apt.' upgrade'.$simulate,
		'repair dependencies' => $apt.' -f install'.$simulate,
		'remove unused packages' => $apt.' autoremove'.$simulate,
	];

	foreach ($steps as $name => $command) {
		exec($command.' 2>&1', $output, $status); //capture the apt output instead of filling up syslog
		if ($debug) {
			foreach ((array) $output as $line) {
				log_message(LOG_DEBUG, $name.': '.$line);
			}
		}
		if ($interactive) {
			echo implode("\n", (array) $output)."\n";
		}
		if ($status !== 0) {
			abort($name.' failed with status '.$status, implode(' | ', array_slice((array) $output, -20)));
		}
		log_message(LOG_INFO, $name.' completed');
	}

//restart the services that got a new version so they are not running the old binary
	if (!$dry_run) {
		foreach ($services as $name => $service) {
			$after = package_versions($service['pattern']);
			$changed = [];
			foreach ($after as $package => $version) {
				if (($before[$name][$package] ?? '') !== $version) {
					$changed[] = $package.' '.$version;
				}
			}
			if (empty($changed)) {
				continue; //nothing changed for this service
			}
			$reason = $name.' upgraded to '.implode(', ', $changed);
			$units = empty($service['unit']) ? array_keys($after) : [$service['unit']];
			foreach ($units as $unit) {
				restart_service($unit, $reason);
			}
		}
	}

//report when a reboot is needed to finish the upgrade
	if (!$dry_run && file_exists('/var/run/reboot-required')) {
		log_message(LOG_WARNING, 'a reboot is required to complete the upgrade');
	}

	log_message(LOG_INFO, 'upgrade'.($dry_run ? ' dry run' : '').' finished in '.(time() - $started).' seconds');
