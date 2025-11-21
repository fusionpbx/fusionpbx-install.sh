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
apt-get install -y wget lsb-release \
  systemd \
  systemd-sysv \
  ca-certificates \
  dialog \
  nano \
  net-tools \
  gpg \
  libpq-dev \
  verbose

#SNMP
apt-get install -y snmpd
echo "rocommunity public" > /etc/snmp/snmpd.conf
service snmpd restart

#disable vi visual mode
echo "set mouse-=a" >> ~/.vimrc

#IPTables
resources/iptables.sh

#sngrep
resources/sngrep.sh

#PHP
resources/php.sh

#NGINX web server
resources/nginx.sh

#FusionPBX
resources/fusionpbx.sh

#Optional Applications
resources/applications.sh

#Fail2ban
resources/fail2ban.sh

#Postgres
resources/postgresql.sh

#FreeSWITCH
resources/switch.sh

#set the ip address
server_address=$(hostname -I)

#add the database schema, user and groups
resources/finish.sh
