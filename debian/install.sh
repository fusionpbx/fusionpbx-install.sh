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
apt-get update && apt-get upgrade -y

#Add dependencies
apt-get install -y wget
apt-get install -y lsb-release
apt-get install -y systemd
apt-get install -y systemd-sysv
apt-get install -y ca-certificates
apt-get install -y dialog
apt-get install -y nano

#SNMP
apt-get install -y snmpd
echo "rocommunity public" > /etc/snmp/snmpd.conf
service snmpd restart

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
if [ ."$php_version" = ."5.6" ]; then
        service php5-fpm restart
fi
if [ ."$php_version" = ."7.0" ]; then
        service php7.0-fpm restart
fi
if [ ."$php_version" = ."7.1" ]; then
        service php7.1-fpm restart
fi
if [ ."$php_version" = ."7.2" ]; then
        service php7.2-fpm restart
fi

service nginx restart
service fail2ban restart

#add the database schema, user and groups
resources/finish.sh
