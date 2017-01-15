#!/bin/sh

#move to script directory so all relative paths work
#cd "$(dirname "$0")"

#initialize variable encase we are called directly
[ -z $USE_FREESWITCH_SOURCE ] && USE_FREESWITCH_SOURCE=false

#send a message
echo "Install Fail2ban"

#add the dependencies
apt-get install -y --force-yes fail2ban

#move the filters
cp resources/fail2ban/freeswitch-dos.conf /etc/fail2ban/filter.d/freeswitch-dos.conf
cp resources/fail2ban/freeswitch-ip.conf /etc/fail2ban/filter.d/freeswitch-ip.conf
cp resources/fail2ban/freeswitch-404.conf /etc/fail2ban/filter.d/freeswitch-404.conf
cp resources/fail2ban/freeswitch.conf /etc/fail2ban/filter.d/freeswitch.conf
cp resources/fail2ban/fusionpbx.conf /etc/fail2ban/filter.d/fusionpbx.conf
cp resources/fail2ban/nginx-404.conf /etc/fail2ban/filter.d/nginx-404.conf
cp resources/fail2ban/nginx-dos.conf /etc/fail2ban/filter.d/nginx-dos.conf
cp resources/fail2ban/jail.local /etc/fail2ban/jail.local

#update config if source is being used
if [ $USE_FREESWITCH_SOURCE = true ]; then
	sed 's#var/log/freeswitch#usr/local/freeswitch/log#g' -i /etc/fail2ban/jail.local
fi

#restart fail2ban
#systemd
/bin/systemctl restart fail2ban

#init.d
#/usr/sbin/service fail2ban restart
