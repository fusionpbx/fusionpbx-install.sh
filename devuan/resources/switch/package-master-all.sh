#!/bin/sh
apt-get update && apt-get install -y -q ntp curl memcached haveged
curl https://files.freeswitch.org/repo/deb/debian/freeswitch_archive_g0.pub | apt-key add -
echo "deb http://files.freeswitch.org/repo/deb/freeswitch-1.6/ jessie main" > /etc/apt/sources.list.d/freeswitch.list
echo "deb http://files.freeswitch.org/repo/deb/debian-unstable/ jessie main" >> /etc/apt/sources.list.d/freeswitch.list
apt-get update && apt-get install -y -q freeswitch-meta-all freeswitch-all-dbg gdb

