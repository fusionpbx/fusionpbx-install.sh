#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ../config.sh
. ../colors.sh
. ../environment.sh

apt-get -q update && apt-get install -y -q ntp curl memcached haveged

if [ ."$cpu_architecture" = ."x86" ]; then
	wget -O - https://files.freeswitch.org/repo/deb/debian-release/fsstretch-archive-keyring.asc | apt-key add -
	echo "deb http://files.freeswitch.org/repo/deb/debian-release/ `lsb_release -sc` main" > /etc/apt/sources.list.d/freeswitch.list
	echo "deb-src http://files.freeswitch.org/repo/deb/debian-release/ `lsb_release -sc` main" >> /etc/apt/sources.list.d/freeswitch.list
fi
apt-get -q update && apt-get install -y -q freeswitch-meta-all freeswitch-all-dbg gdb
