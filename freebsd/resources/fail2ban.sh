#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh

#send a message
verbose "Installing Fail2ban"

#add the dependencies
pkg install --yes py39-fail2ban

#enable fail2ban service
echo 'fail2ban_enable="YES"' >> /etc/rc.conf

#move the filters
cp fail2ban/freeswitch-dos.conf /usr/local/etc/fail2ban/filter.d/freeswitch-dos.conf
cp fail2ban/freeswitch-ip.conf /usr/local/etc/fail2ban/filter.d/freeswitch-ip.conf
cp fail2ban/freeswitch-404.conf /usr/local/etc/fail2ban/filter.d/freeswitch-404.conf
cp fail2ban/freeswitch.conf /usr/local/etc/fail2ban/filter.d/freeswitch.conf
cp fail2ban/fusionpbx.conf /usr/local/etc/fail2ban/filter.d/fusionpbx.conf
cp fail2ban/nginx-404.conf /usr/local/etc/fail2ban/filter.d/nginx-404.conf
cp fail2ban/nginx-dos.conf /usr/local/etc/fail2ban/filter.d/nginx-dos.conf
cp fail2ban/jail.local /usr/local/etc/fail2ban/jail.local
cp fail2ban/sip-auth-challenge-ip.conf /usr/local/etc/fail2ban/filter.d/sip-auth-challenge-ip.conf
cp fail2ban/sip-auth-challenge.conf /usr/local/etc/fail2ban/filter.d/sip-auth-challenge.conf

# Fix default setting for allowipv6 directive
mv /usr/local/etc/fail2ban/fail2ban.conf /usr/local/etc/fail2ban/fail2ban.conf.dist
cat /usr/local/etc/fail2ban/fail2ban.conf.dist | sed '/^#allowipv6/s//allowipv6/' > /usr/local/etc/fail2ban/fail2ban.conf
chown root:wheel /usr/local/etc/fail2ban/fail2ban.conf
chmod 0644 /usr/local/etc/fail2ban/fail2ban.conf

#restart fail2ban
service fail2ban start
