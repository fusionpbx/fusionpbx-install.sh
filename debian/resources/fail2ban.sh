#!/bin/sh

#send a message
echo "Install Fail2ban"

#add the dependencies
apt-get install -y --force-yes  fail2ban

#move the filters
cp resources/fail2ban/fusionpbx.conf /etc/fail2ban/filter.d/fusionpbx.conf
cp resources/fail2ban/freeswitch-dos.conf /etc/fail2ban/filter.d/freeswitch-dos.conf
cp resources/fail2ban/freeswitch.conf /etc/fail2ban/filter.d/freeswitch.conf

#move the template
cp resources/fail2ban/jail.package /etc/fail2ban/jail.package
cp resources/fail2ban/jail.source /etc/fail2ban/jail.source

#active the filters
cp resources/fail2ban/jail.package /etc/fail2ban/jail.local

#restart fail2ban
#systemd
/bin/systemctl restart fail2ban

#init.d
#/usr/sbin/service fail2ban restart
