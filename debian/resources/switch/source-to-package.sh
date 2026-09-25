#!/bin/sh

#make sure the etc fusionpbx directory exists 
mkdir -p /etc/fusionpbx

#remove init.d startup script
mv /etc/init.d/freeswitch /usr/src/init.d.freeswitch
update-rc.d -f freeswitch remove

#add the the freeswitch package
$(dirname $0)/package-release.sh

#install freeswitch systemd.d
$(dirname $0)/package-systemd.sh

#update fail2ban
sed -i /etc/fail2ban/jail.local -e s:'/usr/local/freeswitch/log:/var/log/freeswitch:'
sytemctl restart fail2ban

#move source files to package directories
rsync -avz /usr/local/freeswitch/conf/* /etc/freeswitch
rsync -avz /usr/local/freeswitch/recordings /var/lib/freeswitch
rsync -avz /usr/local/freeswitch/storage /var/lib/freeswitch
rsync -avz /usr/local/freeswitch/scripts /usr/share/freeswitch
