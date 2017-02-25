#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

. ../colors.sh
. ../arguments.sh

verbose "Installing FreeSWITCH"

yum -y install memcached curl gdb
yum install -y http://files.freeswitch.org/freeswitch-release-1-6.noarch.rpm
yum install -y freeswitch-config-vanilla freeswitch-lang-* freeswitch-sounds-* freeswitch-lua freeswitch-xml-cdr

##remove the music package to protect music on hold from package updates
mkdir -p /usr/share/freeswitch/sounds/temp
mv /usr/share/freeswitch/sounds/music/*000 /usr/share/freeswitch/sounds/temp
yum -y remove freeswitch-sounds-music
mkdir -p /usr/share/freeswitch/sounds/music/default
mv /usr/share/freeswitch/sounds/temp/* /usr/share/freeswitch/sounds/music/default
rm -R /usr/share/freeswitch/sounds/temp

verbose "FreeSWITCH installed"

