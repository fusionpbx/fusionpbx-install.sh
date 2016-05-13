#!/bin/sh
apt-get update && apt-get install -y --force-yes curl memcached haveged
USE_UNOFFICIAL_ARM_REPO=0
arch=$(uname -m)
if [ $arch = 'armv7l' ] && [ $USE_UNOFFICIAL_ARM_REPO -eq 1 ]; then
        echo "deb http://repo.sip247.com/debian/freeswitch-stable-armhf/ jessie main" > /etc/apt/sources.list.d/freeswitch.list
        curl http://repo.sip247.com/debian/sip247.com.gpg.key | apt-key add -
else
        echo "deb http://files.freeswitch.org/repo/deb/freeswitch-1.6/ jessie main" > /etc/apt/sources.list.d/freeswitch.list
        curl http://files.freeswitch.org/repo/deb/freeswitch-1.6/key.gpg | apt-key add -
fi
apt-get update
apt-get install -y --force-yes freeswitch-meta-vanilla freeswitch-mod-json-cdr libyuv-dev gdb freeswitch-mod-xml-cdr freeswitch-mod-verto freeswitch-lang-fr freeswitch-mod-say-fr 
apt-get install -y --force-yes freeswitch-mod-rtc freeswitch-mod-png freeswitch-mod-opus freeswitch-mod-b64 freeswitch-mod-distributor freeswitch-mod-esl freeswitch-mod-fifo freeswitch-mod-memcache freeswitch-mod-shout

#set the file permissions
chown -R freeswitch:freeswitch /var/lib/freeswitch
chmod -R g+s /var/lib/freeswitch
setfacl -R -m u:www-data:rwx,g:www-data:rwx /var/lib/freeswitch
setfacl -R -d -m u:www-data:rwx,g:www-data:rwx /var/lib/freeswitch

chown -R freeswitch:freeswitch /usr/share/freeswitch
chmod -R g+s /usr/share/freeswitch
setfacl -R -m u:www-data:rwx,g:www-data:rwx /usr/share/freeswitch
setfacl -R -d -m u:www-data:rwx,g:www-data:rwx /usr/share/freeswitch

chown -R freeswitch:freeswitch /etc/freeswitch
chmod -R g+s /etc/freeswitch
setfacl -R -m u:www-data:rwx,g:www-data:rwx /etc/freeswitch
setfacl -R -d -m u:www-data:rwx,g:www-data:rwx /etc/freeswitch

chown -R freeswitch:freeswitch /var/log/freeswitch
setfacl -R -m u:www-data:rwx,g:www-data:rwx /var/log/freeswitch
setfacl -R -d -m u:www-data:rwx,g:www-data:rwx /var/log/freeswitch

chown -R freeswitch:freeswitch /usr/share/freeswitch/sounds
chmod -R g+s /usr/share/freeswitch/sounds
setfacl -R -m u:www-data:rwx,g:www-data:rwx /usr/share/freeswitch/sounds
setfacl -R -d -m u:www-data:rwx,g:www-data:rwx /usr/share/freeswitch/sounds
