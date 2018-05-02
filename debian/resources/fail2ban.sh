#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh

#send a message
verbose "Installing Fail2ban"

#add the dependencies
apt-get install -y --force-yes fail2ban

#move the filters
cp fail2ban/freeswitch-auth_failure.conf /etc/fail2ban/filter.d/freeswitch-auth_failure.conf
cp fail2ban/freeswitch-auth_challenge.conf /etc/fail2ban/filter.d/freeswitch-auth_challenge.conf
cp fail2ban/freeswitch-ip.conf /etc/fail2ban/filter.d/freeswitch-ip.conf
cp fail2ban/freeswitch.conf /etc/fail2ban/filter.d/freeswitch.conf
cp fail2ban/fusionpbx.conf /etc/fail2ban/filter.d/fusionpbx.conf
cp fail2ban/fusionpbx-mac.conf /etc/fail2ban/filter.d/fusionpbx-mac.conf
cp fail2ban/fusionpbx-404.conf /etc/fail2ban/filter.d/fusionpbx-404.conf
cp fail2ban/nginx-404.conf /etc/fail2ban/filter.d/nginx-404.conf
cp fail2ban/nginx-dos.conf /etc/fail2ban/filter.d/nginx-dos.conf
cp fail2ban/jail.local /etc/fail2ban/jail.local

#update config if source is being used
if [ .$switch_source = .true ]; then
	sed 's#var/log/freeswitch#usr/local/freeswitch/log#g' -i /etc/fail2ban/jail.local
fi

#restart fail2ban
/usr/sbin/service fail2ban restart
