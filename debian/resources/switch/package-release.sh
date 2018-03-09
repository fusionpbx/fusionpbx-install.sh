#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ../config.sh
. ../colors.sh
. ../environment.sh

apt-get update && apt-get install -y --force-yes curl memcached haveged apt-transport-https
if [ ."$cpu_architecture" = ."arm" ]; then
        echo "deb https://repo.fusionpbx.com/armhf jessie 1.6.20" > /etc/apt/sources.list.d/freeswitch.list
        curl https://repo.fusionpbx.com/public.key | apt-key add -
else
        if [ ."$os_codename" = ."stretch" ]; then
                echo "deb https://repo.fusionpbx.com/armhf stretch 1.6.20" > /etc/apt/sources.list.d/freeswitch.list
                curl https://repo.fusionpbx.com/public.key | apt-key add -
        else
                echo "deb http://files.freeswitch.org/repo/deb/freeswitch-1.6/ jessie main" > /etc/apt/sources.list.d/freeswitch.list
                curl http://files.freeswitch.org/repo/deb/freeswitch-1.6/key.gpg | apt-key add -
        fi
fi
apt-get update
apt-get install -y --force-yes gdb ntp
apt-get install -y --force-yes freeswitch-meta-bare freeswitch-conf-vanilla freeswitch-mod-commands freeswitch-mod-console freeswitch-mod-logfile
apt-get install -y --force-yes freeswitch-lang-en freeswitch-mod-say-en freeswitch-sounds-en-us-callie
apt-get install -y --force-yes freeswitch-mod-enum freeswitch-mod-cdr-csv freeswitch-mod-event-socket freeswitch-mod-sofia freeswitch-mod-sofia-dbg freeswitch-mod-loopback
apt-get install -y --force-yes freeswitch-mod-conference freeswitch-mod-db freeswitch-mod-dptools freeswitch-mod-expr freeswitch-mod-fifo freeswitch-mod-httapi
apt-get install -y --force-yes freeswitch-mod-hash freeswitch-mod-esl freeswitch-mod-esf freeswitch-mod-fsv freeswitch-mod-valet-parking freeswitch-mod-dialplan-xml freeswitch-dbg
apt-get install -y --force-yes freeswitch-mod-sndfile freeswitch-mod-native-file freeswitch-mod-local-stream freeswitch-mod-tone-stream freeswitch-mod-lua freeswitch-meta-mod-say
apt-get install -y --force-yes freeswitch-mod-xml-cdr freeswitch-mod-verto freeswitch-mod-callcenter freeswitch-mod-rtc freeswitch-mod-png freeswitch-mod-json-cdr freeswitch-mod-shout
apt-get install -y --force-yes freeswitch-mod-sms freeswitch-mod-sms-dbg freeswitch-mod-cidlookup freeswitch-mod-memcache
apt-get install -y --force-yes freeswitch-mod-imagick freeswitch-mod-tts-commandline freeswitch-mod-directory
apt-get install -y --force-yes freeswitch-mod-skypopen freeswitch-mod-skypopen-dbg freeswitch-mod-flite libyuv-dev freeswitch-mod-distributor freeswitch-meta-codecs
apt-get install -y --force-yes freeswitch-music-default

#make sure that postgresql is started before starting freeswitch
sed -i /lib/systemd/system/freeswitch.service -e s:'local-fs.target:local-fs.target postgresql.service:'

#remove the music package to protect music on hold from package updates
mkdir -p /usr/share/freeswitch/sounds/temp
mv /usr/share/freeswitch/sounds/music/*000 /usr/share/freeswitch/sounds/temp
mv /usr/share/freeswitch/sounds/music/default/*000 /usr/share/freeswitch/sounds/temp
apt-get remove -y --force-yes freeswitch-music-default
mkdir -p /usr/share/freeswitch/sounds/music/default
mv /usr/share/freeswitch/sounds/temp/* /usr/share/freeswitch/sounds/music/default
rm -R /usr/share/freeswitch/sounds/temp
