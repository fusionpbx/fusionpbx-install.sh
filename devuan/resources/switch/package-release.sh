#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ../config.sh
. ../colors.sh
. ../environment.sh

apt-get -qq -y install curl memcached haveged
if [ ."$cpu_architecture" = ."arm" ]; then
        echo "deb http://repo.sip247.com/debian/freeswitch-stable-armhf/ jessie main" > /etc/apt/sources.list.d/freeswitch.list
        curl http://repo.sip247.com/debian/sip247.com.gpg.key | apt-key add -
        apt-get -q update
else
        echo "deb http://files.freeswitch.org/repo/deb/freeswitch-1.6/ jessie main" > /etc/apt/sources.list.d/freeswitch.list
        curl http://files.freeswitch.org/repo/deb/freeswitch-1.6/key.gpg | apt-key add -
        apt-get -q update
fi

apt-get -qq -y install gdb ntp
apt-get -qq -y install freeswitch-meta-bare freeswitch-conf-vanilla freeswitch-sysvinit freeswitch-mod-commands freeswitch-meta-codecs freeswitch-mod-console freeswitch-mod-logfile freeswitch-mod-distributor
apt-get -qq -y install freeswitch-lang-en freeswitch-mod-say-en freeswitch-sounds-en-us-callie
apt-get -qq -y install freeswitch-mod-enum freeswitch-mod-cdr-csv freeswitch-mod-event-socket freeswitch-mod-sofia freeswitch-mod-sofia-dbg freeswitch-mod-loopback
apt-get -qq -y install freeswitch-mod-conference freeswitch-mod-db freeswitch-mod-dptools freeswitch-mod-expr freeswitch-mod-fifo libyuv-dev freeswitch-mod-httapi
apt-get -qq -y install freeswitch-mod-hash freeswitch-mod-esl freeswitch-mod-esf freeswitch-mod-fsv freeswitch-mod-valet-parking freeswitch-mod-dialplan-xml freeswitch-dbg
apt-get -qq -y install freeswitch-mod-sndfile freeswitch-mod-native-file freeswitch-mod-local-stream freeswitch-mod-tone-stream freeswitch-mod-lua freeswitch-meta-mod-say
apt-get -qq -y install freeswitch-mod-xml-cdr freeswitch-mod-verto freeswitch-mod-callcenter freeswitch-mod-rtc freeswitch-mod-png freeswitch-mod-json-cdr freeswitch-mod-shout
apt-get -qq -y install freeswitch-mod-skypopen freeswitch-mod-skypopen-dbg freeswitch-mod-sms freeswitch-mod-sms-dbg freeswitch-mod-cidlookup freeswitch-mod-memcache
apt-get -qq -y install freeswitch-mod-imagick freeswitch-mod-tts-commandline freeswitch-mod-directory freeswitch-mod-flite
apt-get -qq -y install freeswitch-music-default
apt-get remove -q -y freeswitch-systemd

#remove the music package to protect music on hold from package updates
mkdir -p /usr/share/freeswitch/sounds/temp
mv /usr/share/freeswitch/sounds/music/*000 /usr/share/freeswitch/sounds/temp
apt-get remove -y freeswitch-music-default
mkdir -p /usr/share/freeswitch/sounds/music/default
mv /usr/share/freeswitch/sounds/temp/* /usr/share/freeswitch/sounds/music/default
rm -R /usr/share/freeswitch/sounds/temp
