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

if [ $CPU_CHECK = true ]; then
	#check what the CPU is
	OS_bits=$(uname -m)
	OS_arch=$(uname -m)
	CPU_bits='i686'
	if [ $(grep -o -w 'lm' /proc/cpuinfo) = 'lm' ]; then
		CPU_bits='x86_64'	
	fi
	
	if [ $USE_SWITCH_SOURCE = false ]; then
		if [ $OS_arch = 'armv7l' ]; then
			if [ $USE_SWITCH_PACKAGE_UNOFFICIAL_ARM = false && OS_bits = 'i686' ]; then
				error "You are using a 32bit arm OS this is unsupported"
				warning " please rerun with either --use-switch-package-unofficial-arm or --use-switch-source"
				exit 3
			fi
		else
			if [ $OS_bits = 'i686' ]; then
				error "You are using a 32bit OS this is unsupported"
				if [ $CPU_bits = 'x86_64' ]; then
					error "Your CPU is 64bit you should consider reinstalling with a 64bit OS"
				fi
				warning " please rerun with --use-switch-source"
				exit 3
			fi
		fi
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

#Fail2ban
resources/fail2ban.sh

#FreeSWITCH
if [ $USE_SWITCH_SOURCE = true ]; then
	if [ $USE_SWITCH_MASTER = true ]; then
		resources/switch/source-master.sh
	else
		resources/switch/source-release.sh
	fi
	resources/switch/source-permissions.sh
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
	resources/switch/package-permissions.sh
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
