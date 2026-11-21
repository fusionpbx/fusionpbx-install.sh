<?php
/*

Upgrade Debian Packages
- Updates the package lists, upgrades packages, repairs dependencies and cleans up.
- Runs non interactive so existing configuration files are kept and no prompt can hang cron.
- Waits for another apt process instead of skipping a scheduled run when they collide.
- Restarts php-fpm and nginx when their package version changes during the upgrade, the Debian
  package scripts usually restart them too so these restarts are a safety net. PostgreSQL is not
  restarted here, an updated postgresql binary keeps running until you restart it yourself.
- Stops on the first error and exits non zero so cron or monit can report it.
- Uses upgrade instead of dist-upgrade so dependency resolution never removes a package.
- The last step runs autoremove which does remove packages that are no longer required, skip it
  with --no-autoremove. When it fails the run is still reported as incomplete but the upgrades
  and the service restarts have already happened.

Logging goes to syslog with the tag fusionpbx-upgrade. View the log on Debian with:
	journalctl -t fusionpbx-upgrade			all entries, newest last
	journalctl -t fusionpbx-upgrade -n 50		the last 50 lines
	journalctl -t fusionpbx-upgrade --since today	only today
	journalctl -t fusionpbx-upgrade -p err		failures only
	journalctl -t fusionpbx-upgrade -f			follow it while the script runs
	grep fusionpbx-upgrade /var/log/syslog		only when rsyslog is installed
The apt output is captured rather than logged so that syslog stays short, one line per step.
Use --debug to log every apt line as well, see those with journalctl -t fusionpbx-upgrade -p debug.

Flags
	--dry-run	simulate the changes, no package is installed, removed or restarted
			the package lists are still refreshed so that the simulation is accurate
	--debug	log all apt output to syslog at debug level
	--no-autoremove	skip the autoremove step so nothing is removed by this script
A manual run from a terminal also mirrors the messages and the apt output on the screen.

Run manually like this.
/usr/bin/php /usr/src/fusionpbx-install.sh/debian/resources/maintenance/upgrade.php
/usr/bin/php /usr/src/fusionpbx-install.sh/debian/resources/maintenance/upgrade.php --dry-run

Debian, run as root every morning at 5:15 am when the system is quiet (crontab -e).
MAILTO=root
15 5 * * * /usr/bin/php /usr/src/fusionpbx-install.sh/debian/resources/maintenance/upgrade.php

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
	$no_autoremove = in_array('--no-autoremove', $_SERVER['argv'] ?? []);
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

//run a command and return its output lines, exec() appends so the array starts empty every time
	function run_command($command, &$status) {
		$output = [];
		exec($command.' 2>&1', $output, $status);
		return $output;
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
		run_command('/bin/systemctl is-active --quiet '.escapeshellarg($unit).'.service', $status);
		if ($status !== 0) {
			log_message(LOG_WARNING, $unit.' is not running, skipped ('.$reason.')');
			return;
		}
		log_message(LOG_NOTICE, 'restarting '.$unit.': '.$reason);
		$output = run_command('/bin/systemctl restart '.escapeshellarg($unit.'.service'), $status);
		if ($status !== 0) {
			abort('unable to restart '.$unit.', check systemctl status '.$unit.'.service', implode(' | ', $output));
		}
		log_message(LOG_NOTICE, $unit.' restarted');
	}

//only root can install packages
	if (function_exists('posix_geteuid') && posix_geteuid() !== 0) {
		abort('this script must be run as root');
	}

//stop when the disk is too full to finish an install
	$free = disk_free_space('/var');
	if ($free === false) {
		log_message(LOG_WARNING, 'cannot check the free space on /var, continuing');
	} elseif ((int) round($free / 1024 / 1024) < $min_free_mb) {
		abort('only '.(int) round($free / 1024 / 1024).' MB free on /var, at least '.$min_free_mb.' MB is needed');
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
			$check = run_command('/usr/bin/apt-get -q check', $status);
			if ($status === 0) {
				break; //nothing else is using apt
			}
			if (strpos(strtolower(implode("\n", $check)), 'lock') === false) {
				//not a lock, report it and let the repair dependencies step try to fix it
				log_message(LOG_WARNING, 'apt check reported: '.implode(' | ', array_slice($check, -5)));
				break;
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

//debian does not create /var/run/reboot-required so remember the kernel packages as well
	$kernel_before = package_versions('linux-image*');

//log what ran and how long it took, one line per step keeps syslog readable
	log_message(LOG_INFO, 'upgrade'.($dry_run ? ' dry run' : '').' started on '.gethostname());
	$started = time();

//run the steps in order, only autoremove may fail without stopping the rest
	$steps = [
		//the lists are always refreshed so that a simulation is accurate
		'update package lists' => ['command' => $apt.' update', 'required' => true],
		'upgrade packages' => ['command' => $apt.' upgrade'.$simulate, 'required' => true],
		'repair dependencies' => ['command' => $apt.' -f install'.$simulate, 'required' => true],
	];

//autoremove does remove unused packages, --no-autoremove skips the step completely
	if (!$no_autoremove) {
		$steps['remove unused packages'] = ['command' => $apt.' autoremove'.$simulate, 'required' => false];
	}

	$incomplete = false;
	foreach ($steps as $name => $step) {
		$output = run_command($step['command'], $status); //capture the apt output instead of filling up syslog
		if ($debug) {
			foreach ($output as $line) {
				log_message(LOG_DEBUG, $name.': '.$line);
			}
		}
		if ($interactive) {
			echo implode("\n", $output)."\n";
		}
		if ($status !== 0) {
			$detail = implode(' | ', array_slice($output, -20));
			if ($step['required']) {
				abort($name.' failed with status '.$status, $detail);
			}
			log_message(LOG_WARNING, $name.' failed with status '.$status.', continuing: '.$detail);
			$incomplete = true;
			continue;
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
	if (!$dry_run) {
		if (file_exists('/var/run/reboot-required')) {
			log_message(LOG_WARNING, 'a reboot is required to complete the upgrade');
		}
		foreach (package_versions('linux-image*') as $package => $version) {
			if (($kernel_before[$package] ?? '') !== $version) {
				log_message(LOG_WARNING, $package.' was upgraded to '.$version.', reboot when the system is quiet');
				break; //one warning is enough
			}
		}
	}

//a failed autoremove is reported but it did not stop the upgrades or the service restarts
	if ($incomplete) {
		log_message(LOG_ERR, 'upgrade'.($dry_run ? ' dry run' : '').' finished with warnings in '.(time() - $started).' seconds');
		exit(1);
	}

	log_message(LOG_INFO, 'upgrade'.($dry_run ? ' dry run' : '').' finished in '.(time() - $started).' seconds');
