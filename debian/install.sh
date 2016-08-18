#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

. resources/colors.sh

#Process command line options
ARGS=$(getopt -n 'install.sh' -o h -l help,use-switch-source,use-switch-package-all,use-switch-master,use-switch-package-unofficial-arm,no-cpu-check -- "$@")

if [ $? -ne 0 ]; then
	error "Failed parsing options."
	exit 1
fi

export USE_SWITCH_SOURCE=false
export USE_SWITCH_PACKAGE_ALL=false
export USE_SWITCH_PACKAGE_UNOFFICIAL_ARM=false
export USE_SWITCH_MASTER=false
export CPU_CHECK=true
HELP=false

while true; do
  case "$1" in
    --use-switch-source ) export USE_SWITCH_SOURCE=true; shift ;;
    --use-switch-package-all ) export USE_SWITCH_PACKAGE_ALL=true; shift ;;
    --use-switch-package-unofficial-arm ) export USE_SWITCH_PACKAGE_UNOFFICIAL_ARM=true; shift ;;
    --use-switch-master ) export USE_SWITCH_MASTER=true; shift ;;
    --no-cpu-check ) export CPU_CHECK=false; shift ;;
    -h | --help ) HELP=true; shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

if [ $HELP = true ]; then
	warning "Debian installer script"
	warning "	--use-switch-source will use freeswitch from source rather than ${green}(default:packages)"
	warning "	--use-switch-package-all if using packages use the meta-all package"
	warning "	--use-switch-package-unofficial-arm if your system is arm and you are using packages, use the unofficial arm repo"
	warning "	--use-switch-master will use master branch/packages instead of ${green}(default:stable)"
	warning "	--no-cpu-check disable the cpu check ${green}(default:check)"
	exit;
fi

if [ $CPU_CHECK = true ] && [ $USE_SWITCH_SOURCE = false ]; then
	#check what the CPU and OS are
	OS_test=$(uname -m)
	CPU_arch='unknown'
	OS_bits='unknown'
	CPU_bits='unknown'
	if [ $OS_test = 'armv7l' ]; then
		OS_bits='32'
		CPU_bits='32'
		# RaspberryPi 3 is actually armv8l but current Raspbian reports the cpu as armv7l and no Raspbian 64Bit has been released at this time
		CPU_arch='arm'
	elif [ $OS_test = 'armv8l' ]; then
		# We currently have no test case for armv8l
		OS_bits='unknown'
		CPU_bits='64'
		CPU_arch='arm'
	elif [ $OS_test = 'i386' ]; then
		OS_bits='32'
	if [ "$(grep -o -w 'lm' /proc/cpuinfo)" = 'lm' ]; then
			CPU_bits='64'
		else
			CPU_bits='32'
		fi
		CPU_arch='x86'
	elif [ $OS_test = 'i686' ]; then
		OS_bits='32'
		if [ $(grep -o -w 'lm' /proc/cpuinfo) = 'lm' ]; then
			CPU_bits='64'
		else
			CPU_bits='32'
		fi
		CPU_arch='x86'
	elif [ $OS_test = 'x86_64' ]; then
		OS_bits='64'
		if [ $(grep -o -w 'lm' /proc/cpuinfo) = 'lm' ]; then
			CPU_bits='64'
		else
			CPU_bits='32'
		fi
		CPU_arch='x86'
	fi
	
	if [ $CPU_arch = 'arm' ]; then
		if [ $OS_bits = '32' ]; then
			if [ $USE_SWITCH_PACKAGE_UNOFFICIAL_ARM = false ]; then
				error "You are using a 32bit arm OS this is unsupported"
				warning " please rerun with either --use-switch-package-unofficial-arm or --use-switch-source"
				exit 3
			else
				verbose "Correct CPU/OS detected, using unofficial arm repo"
			fi
		elif [ $OS_bits = '64' ]; then
			error "You are using a 64bit arm OS this is unsupported"
			warning " please rerun with --use-switch-source"
			exit 3
		else
			error "Unknown OS_bits $OS_bits this is unsupported"
			warning " please rerun with --use-switch-source"
			exit 3
		fi
	elif [ $CPU_arch = 'x86' ]; then
		if [ $OS_bits = '32' ]; then
			error "You are using a 32bit OS this is unsupported"
			if [ $CPU_bits = '64' ]; then
				warning " Your CPU is 64bit you should consider reinstalling with a 64bit OS"
			fi
			warning " please rerun with --use-switch-source"
			exit 3
		elif [ $OS_bits = '64' ]; then
			verbose "Correct CPU/OS detected"
		else
			error "Unknown OS_bits $OS_bits this is unsupported"
			warning " please rerun with --use-switch-source"
			exit 3
		fi
	else
		error "You are using a unsupported architecture $CPU_arch"
	fi
fi

# removes the cd img from the /etc/apt/sources.list file (not needed after base install)
sed -i '/cdrom:/d' /etc/apt/sources.list

#Update Debian
verbose "Update Debian"
apt-get upgrade && apt-get update -y --force-yes

#IPTables
resources/iptables.sh

#FusionPBX
resources/fusionpbx.sh

#NGINX web server
resources/nginx.sh

#PHP
resources/php.sh

#Fail2ban
resources/fail2ban.sh

#FreeSWITCH
if [ $USE_SWITCH_SOURCE = true ]; then
	if [ $USE_SWITCH_MASTER = true ]; then
		resources/switch/source-master.sh
	else
		resources/switch/source-release.sh
	fi

	#copy the switch conf files to /etc/freeswitch
	resources/switch/conf-copy.sh

	#set the file permissions
	resources/switch/source-permissions.sh

	#systemd service
	resources/switch/source-systemd.sh

else
	if [ $USE_SWITCH_MASTER = true ]; then
		if [ $USE_SWITCH_PACKAGE_ALL = true ]; then
			resources/switch/package-master-all.sh
		else
			resources/switch/package-master.sh
		fi
	else
		if [ $USE_SWITCH_PACKAGE_ALL = true ]; then
			resources/switch/package-all.sh
		else
			resources/switch/package-release.sh
		fi
	fi

	#copy the switch conf files to /etc/freeswitch
	resources/switch/conf-copy.sh

	#set the file permissions
	resources/switch/package-permissions.sh

	#systemd service
	resources/switch/package-systemd.sh

fi

#Postgres
resources/postgres.sh

#set the ip address
server_address=$(hostname -I)

#restart services
systemctl daemon-reload
systemctl try-restart freeswitch
systemctl daemon-reload
systemctl restart php5-fpm
systemctl restart nginx
systemctl restart fail2ban

#Show database password
verbose "Complete the install by by going to the IP address of this server ";
verbose "in your web browser or with a domain name for this server.";
echo "   https://$server_address"
echo ""
echo ""

#wait for the config.php to exist and then restart the service
#resources/./finish.sh
