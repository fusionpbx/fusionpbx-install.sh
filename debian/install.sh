#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./resources/config.sh
. ./resources/colors.sh
. ./resources/environment.sh

# removes the cd img from the /etc/apt/sources.list file (not needed after base install)
sed -i '/cdrom:/d' /etc/apt/sources.list

#Update to latest packages
verbose "Update installed packages"
apt-get update && apt-get upgrade -y --force-yes

#Add dependencies
apt-get install -y lsb-release

#IPTables
resources/iptables.sh

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
resources/postgresql.sh

#set the ip address
server_address=$(hostname -I)

#restart services
systemctl daemon-reload
if [ ."$php_version" = ."5" ]; then
        systemctl restart php5-fpm
fi
if [ ."$php_version" = ."7" ]; then
        systemctl restart php7.0-fpm
fi
systemctl restart nginx
systemctl restart fail2ban

#add the database schema, user and groups
resources/finish.sh
