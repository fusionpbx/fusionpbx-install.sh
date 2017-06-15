#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./resources/config.sh
. ./resources/colors.sh
. ./resources/environment.sh

#Update to latest packages
verbose "Update installed packages"
pkg upgrade --yes

#Update the ports
if [ -e "/usr/ports" ]; then
	echo "/usr/ports exists"
	portsnap fetch update
	echo "/usr/ports updated"
else
        echo "/usr/ports not found";
	portsnap fetch extract
	echo "/usr/ports added"
fi

#PF - Packet Filter
resources/pf.sh

#sngrep
resources/sngrep.sh

#FusionPBX
resources/fusionpbx.sh

#NGINX web server
resources/nginx.sh

#PHP
resources/php.sh

#Fail2ban
resources/fail2ban.sh

#FreeSWITCH
resources/switch.sh

#Postgres
resources/postgres.sh

#restart services
service php-fpm restart
service nginx restart
service fail2ban restart

#add the database schema, user and groups
resources/finish.sh
