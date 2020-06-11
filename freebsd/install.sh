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
if [ .$portsnap_enabled = .'true' ]; then
	if [ -f /usr/ports/UPDATING ]; then
		portsnap fetch && portsnap update
		echo "/usr/ports updated"
	else
		portsnap fetch extract
		echo "/usr/ports added"
	fi
fi

#PF - Packet Filter
if [ .$firewall_enabled = .'true' ]; then
	resources/pf.sh
fi

#sngrep
if [ .$sngrep_enabled = .'true' ]; then
	resources/sngrep.sh
fi

#FusionPBX
if [ .$nginx_enabled = .'true' ]; then
	resources/fusionpbx.sh
fi

#NGINX web server
if [ .$nginx_enabled = .'true' ]; then
	resources/nginx.sh
fi

#Fail2ban
if [ .$fail2ban_enabled = .'true' ]; then
	resources/fail2ban.sh
fi

#FreeSWITCH
if [ .$switch_enabled = .'true' ]; then
	resources/switch.sh
fi

#Postgres
if [ .$database_enabled = .'true' ]; then
	resources/postgresql.sh
fi

#restart services
if [ .$nginx_enabled = .'true' ]; then
	service php-fpm restart
	service nginx restart
fi
if [ .$fail2ban_enabled = .'true' ]; then
	service fail2ban restart
fi

#add the database schema, user and groups
resources/finish.sh
