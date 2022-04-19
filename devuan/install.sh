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
apt-get install -y wget
apt-get install -y lsb-release
apt-get install -y ca-certificates
apt-get install -y dialog
apt-get install -y nano
apt-get install -y net-tools

#SNMP
apt-get install -y snmpd
echo "rocommunity public" > /etc/snmp/snmpd.conf
service snmpd restart

#IPTables
resources/iptables.sh

#Optional CLI SIP monitoring tool
resources/sngrep.sh

#FusionPBX
resources/fusionpbx.sh

#PHP
resources/php.sh

#NGINX web server
resources/nginx.sh

#Postgres
resources/postgresql.sh

#FreeSWITCH
resources/switch.sh

#Fail2ban
resources/fail2ban.sh

#set the ip address
server_address=$(hostname -I)

#add the database schema, user and groups
resources/finish.sh
