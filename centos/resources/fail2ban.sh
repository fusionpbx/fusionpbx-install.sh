#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh

#send a message
verbose "Installing Fail2ban"

#add the dependencies
yum -y install fail2ban

#move the filters
cp ./fail2ban/freeswitch-dos.conf /etc/fail2ban/filter.d/freeswitch-dos.conf
cp ./fail2ban/freeswitch-ip.conf /etc/fail2ban/filter.d/freeswitch-ip.conf
cp ./fail2ban/freeswitch-404.conf /etc/fail2ban/filter.d/freeswitch-404.conf
cp ./fail2ban/freeswitch.conf /etc/fail2ban/filter.d/freeswitch.conf
cp ./fail2ban/fusionpbx.conf /etc/fail2ban/filter.d/fusionpbx.conf
cp ./fail2ban/nginx-404.conf /etc/fail2ban/filter.d/nginx-404.conf
cp ./fail2ban/nginx-dos.conf /etc/fail2ban/filter.d/nginx-dos.conf
cp ./fail2ban/jail.local /etc/fail2ban/jail.local

#update config if source is being used
if [ .$switch_source = .true ]; then
       sed 's#var/log/freeswitch#usr/local/freeswitch/log#g' -i /etc/fail2ban/jail.local
fi

#restart fail2ban
systemctl restart fail2ban

#send a message
verbose "Fail2ban installed"
