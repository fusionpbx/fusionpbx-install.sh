#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./resources/config.sh
. ./resources/colors.sh
. ./resources/environment.sh

#Update to latest packages
verbose "Update installed packages"
#apt-get upgrade && apt-get update -y --force-yes
# --force-yes is dangerous as per the man page. Lets use -y
apt-get -q update && apt-get -q --assume-yes upgrade

#Add dependencies
apt-get install -q -y lsb-release sudo

#IPTables
resources/iptables.sh

#FusionPBX
resources/fusionpbx.sh

#NGINX web server
resources/nginx.sh

#PHP
resources/php.sh

#FreeSWITCH
resources/switch.sh

#Fail2ban
resources/fail2ban.sh

#Optional CLI SIP monitoring tool
resources/sngrep.sh

#Postgres
resources/postgresql.sh

#restart services
if [ ."$php_version" = ."5" ]; then
        service php5-fpm restart
fi
if [ ."$php_version" = ."7" ]; then
        service php7.0-fpm restart
fi

service nginx restart
service fail2ban restart

#add the database schema, user and groups
resources/finish.sh
