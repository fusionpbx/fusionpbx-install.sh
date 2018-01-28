#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ../config.sh
. ../colors.sh
. ../environment.sh
. ../arguments.sh

apt-get -q update && apt-get install -y -q ntp curl memcached haveged

if [ ."$cpu_architecture" = ."arm" ]; then
        echo "deb http://repo.sip247.com/debian/freeswitch-stable-armhf/ jessie main" > /etc/apt/sources.list.d/freeswitch.list
        curl http://repo.sip247.com/debian/sip247.com.gpg.key | apt-key add -
else
        echo "deb http://files.freeswitch.org/repo/deb/freeswitch-1.6/ jessie main" > /etc/apt/sources.list.d/freeswitch.list
        curl http://files.freeswitch.org/repo/deb/freeswitch-1.6/key.gpg | apt-key add -
fi
apt-get -q update && apt-get install -y -q freeswitch-meta-all freeswitch-all-dbg gdb
