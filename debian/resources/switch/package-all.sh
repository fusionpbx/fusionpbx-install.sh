#!/bin/sh

#initialize variable encase we are called directly
[ -z $USE_SWITCH_PACKAGE_UNOFFICIAL_ARM ] && USE_SWITCH_PACKAGE_UNOFFICIAL_ARM=false

apt-get update && apt-get install -y --force-yes ntp curl memcached haveged
arch=$(uname -m)
if [ $arch = 'armv7l' ] && [ $USE_SWITCH_PACKAGE_UNOFFICIAL_ARM = true ]; then
        echo "deb http://repo.sip247.com/debian/freeswitch-stable-armhf/ jessie main" > /etc/apt/sources.list.d/freeswitch.list
        curl http://repo.sip247.com/debian/sip247.com.gpg.key | apt-key add -
else
        echo "deb http://files.freeswitch.org/repo/deb/freeswitch-1.6/ jessie main" > /etc/apt/sources.list.d/freeswitch.list
        curl http://files.freeswitch.org/repo/deb/freeswitch-1.6/key.gpg | apt-key add -
fi
apt-get update && apt-get install -y --force-yes freeswitch-meta-all freeswitch-all-dbg gdb

#make sure that postgresql is started before starting freeswitch
sed -i /lib/systemd/system/freeswitch.service -e s:'local-fs.target:local-fs.target postgresql.service:'
