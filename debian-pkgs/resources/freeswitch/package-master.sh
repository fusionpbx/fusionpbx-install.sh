#!/bin/sh
apt-get update && apt-get install -y --force-yes curl memcached haveged
curl https://files.freeswitch.org/repo/deb/debian/freeswitch_archive_g0.pub | apt-key add -
echo "deb http://files.freeswitch.org/repo/deb/freeswitch-1.6/ jessie main" > /etc/apt/sources.list.d/freeswitch.list
echo "deb http://files.freeswitch.org/repo/deb/debian-unstable/ jessie main" >> /etc/apt/sources.list.d/freeswitch.list
apt-get update && apt-get install -y --force-yes freeswitch-all freeswitch-all-dbg gdb
#apt-get remove freeswitch-all freeswitch-all-dbg
#rm /etc/apt/sources.list.d/freeswitch.list

#set the file permissions
chown -R freeswitch:freeswitch /var/lib/freeswitch
chmod -R g+s /var/lib/freeswitch
setfacl -R -m u:www-data:rwx,g:www-data:rwx /var/lib/freeswitch
setfacl -R -m d:u:www-data:rwx,d:g:www-data:rwx /var/lib/freeswitch

chown -R freeswitch:freeswitch /usr/share/freeswitch
chmod -R g+s /usr/share/freeswitch
setfacl -R -m u:www-data:rwx,g:www-data:rwx /usr/share/freeswitch
setfacl -R -m d:u:www-data:rwx,d:g:www-data:rwx /usr/share/freeswitch

chown -R freeswitch:freeswitch /etc/freeswitch
chmod -R g+s /etc/freeswitch
setfacl -R -m u:www-data:rwx,g:www-data:rwx /etc/freeswitch
setfacl -R -m d:u:www-data:rwx,d:g:www-data:rwx /etc/freeswitch

chown -R freeswitch:freeswitch /var/log/freeswitch
setfacl -R -m u:www-data:rwx,g:www-data:rwx /var/log/freeswitch
setfacl -R -m d:u:www-data:rwx,d:g:www-data:rwx /var/log/freeswitch

chown -R freeswitch:freeswitch /usr/share/freeswitch/sounds
chmod -R g+s /usr/share/freeswitch/sounds
setfacl -R -m u:www-data:rwx,g:www-data:rwx /usr/share/freeswitch/sounds
setfacl -R -m d:u:www-data:rwx,d:g:www-data:rwx /usr/share/freeswitch/sounds
