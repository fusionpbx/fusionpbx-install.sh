#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ../config.sh
. ../colors.sh
. ../environment.sh

apt-get update && apt-get install -y ntp curl memcached haveged apt-transport-https
apt-get update && apt-get install -y wget lsb-release gnupg2

if [ ."$cpu_architecture" = ."x86" ]; then
	wget -O - https://files.freeswitch.org/repo/deb/debian-release/fsstretch-archive-keyring.asc | apt-key add -
	echo "deb http://files.freeswitch.org/repo/deb/debian-release/ ${os_codename_debian} main" > /etc/apt/sources.list.d/freeswitch.list
	echo "deb-src http://files.freeswitch.org/repo/deb/debian-release/ ${os_codename_debian} main" >> /etc/apt/sources.list.d/freeswitch.list
fi
if [ ."$cpu_architecture" = ."arm" ]; then
	wget -O - https://files.freeswitch.org/repo/deb/rpi/debian-release/freeswitch_archive_g0.pub | apt-key add -
	echo "deb http://files.freeswitch.org/repo/deb/rpi/debian-release/ ${os_codename_debian} main" > /etc/apt/sources.list.d/freeswitch.list
	echo "deb-src http://files.freeswitch.org/repo/deb/rpi/debian-release/ ${os_codename_debian} main" >> /etc/apt/sources.list.d/freeswitch.list
fi
apt-get update && apt-get install -y freeswitch-meta-all freeswitch-all-dbg gdb
