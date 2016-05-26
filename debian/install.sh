#!/bin/sh

#Process command line options
OPTS=`getopt -n 'install.sh' -o h -l help,use-freeswitch-source,use-freeswitch-package-all,use-freeswitch-master -- "$@"`
eval set -- "$OPTS"

if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

USE_FREESWITCH_SOURCE=false
USE_FREESWITCH_PACKAGE_ALL=false
USE_FREESWITCH_MASTER=false
HELP=false

while true; do
  case "$1" in
    --use-freeswitch-source ) USE_FREESWITCH_SOURCE=true; shift ;;
    --use-freeswitch-package-all ) USE_FREESWITCH_PACKAGE_ALL=true; shift ;;
    --use-freeswitch-master ) USE_FREESWITCH_MASTER=true; shift ;;
    -h | --help ) HELP=true; shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

if [ $HELP = true ]; then
	echo "Debian installer script"
	echo "	--use-freeswitch-source will use freeswitch from source rather than (default:packages)"
	echo "	--use-freeswitch-package-all if using packages use the meta-all package"
	echo "	--use-freeswitch-master will use master branch/packages instead of (default:stable)"
	exit;
fi

#Update Debian
echo "Update Debian"
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
if [ $USE_FREESWITCH_SOURCE = true ]; then
	if [ $USE_FREESWITCH_MASTER = true ]; then
		resources/switch/source-master.sh
	else
		resources/switch/source-release.sh
	fi
	resources/switch/source-permissions.sh
else
	if [ $USE_FREESWITCH_MASER = true ]; then
		if [ $USE_FREESWITCH_PACKAGE_ALL = true ]; then
			resources/switch/package-master-all.sh
		else
			resources/switch/package-master.sh
		fi
	else
		if [ $USE_FREESWITCH_PACKAGE_ALL = true ]; then
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
/bin/systemctl daemon-reload
/bin/systemctl try-restart freeswitch
/bin/systemctl daemon-reload
/bin/systemctl restart php5-fpm
/bin/systemctl restart nginx
/bin/systemctl restart fail2ban

#Show database password
echo "Complete the install by by going to the IP address of this server ";
echo "in your web browser or with a domain name for this server.";
echo "   https://$server_address"
echo ""
echo ""

#wait for the config.php to exist and then restart the service
#resources/./finish.sh
