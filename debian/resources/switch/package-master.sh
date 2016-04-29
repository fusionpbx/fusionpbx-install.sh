#!/bin/sh
apt-get update && apt-get install -y --force-yes curl memcached haveged
curl https://files.freeswitch.org/repo/deb/debian/freeswitch_archive_g0.pub | apt-key add -
echo "deb http://files.freeswitch.org/repo/deb/freeswitch-1.6/ jessie main" > /etc/apt/sources.list.d/freeswitch.list
echo "deb http://files.freeswitch.org/repo/deb/debian-unstable/ jessie main" >> /etc/apt/sources.list.d/freeswitch.list
apt-get update && apt-get install -y --force-yes freeswitch-all freeswitch-all-dbg gdb
#apt-get remove freeswitch-all freeswitch-all-dbg
#rm /etc/apt/sources.list.d/freeswitch.list
