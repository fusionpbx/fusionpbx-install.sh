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
apt-get install -y --force-yes freeswitch-meta-bare freeswitch-conf-vanilla freeswitch-systemd freeswitch-mod-commands freeswitch-meta-codecs freeswitch-mod-console freeswitch-mod-logfile freeswitch-mod-distributor gdb
apt-get install -y --force-yes freeswitch-mod-enum freeswitch-mod-cdr-csv freeswitch-mod-event-socket freeswitch-mod-sofia freeswitch-mod-sofia-dbg freeswitch-mod-loopback
apt-get install -y --force-yes freeswitch-mod-conference freeswitch-mod-db freeswitch-mod-dptools freeswitch-mod-expr freeswitch-mod-fifo libyuv-dev freeswitch-mod-httapi
apt-get install -y --force-yes freeswitch-mod-hash freeswitch-mod-esl freeswitch-mod-esf freeswitch-mod-fsv freeswitch-mod-valet-parking freeswitch-mod-dialplan-xml freeswitch-dbg
apt-get install -y --force-yes freeswitch-mod-sndfile freeswitch-mod-native-file freeswitch-mod-local-stream freeswitch-mod-tone-stream freeswitch-mod-lua freeswitch-meta-mod-say
apt-get install -y --force-yes freeswitch-mod-xml-cdr freeswitch-mod-verto freeswitch-mod-callcenter freeswitch-mod-rtc freeswitch-mod-png freeswitch-mod-json-cdr freeswitch-mod-shout
apt-get install -y --force-yes freeswitch-mod-skypopen freeswitch-mod-skypopen-dbg freeswitch-mod-sms freeswitch-mod-sms-dbg freeswitch-mod-cidlookup freeswitch-mod-memcache
apt-get install -y --force-yes freeswitch-mod-imagick freeswitch-mod-tts-commandline freeswitch-mod-directory freeswitch-mod-flite

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
