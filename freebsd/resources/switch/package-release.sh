#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ../config.sh

#install dependencies
pkg install --yes tiff ghostscript10-10.02.1 memcached sox

#set the current working directory
cwd=$(pwd)

#send a message
echo "Installing the FreeSWITCH package"

#install the package
if [ .$switch_source = ."package" ]; then
	pkg install --yes freeswitch
fi
if [ .$switch_source = ."port" ]; then
	#dbatch uses the defaults alternative is make config-recursive
	cd /usr/ports/net/freeswitch/ && make -DBATCH install clean
fi

#set the original working directory
cd $cwd

#configure system service
#cp "$(dirname $0)/rc.d.freeswitch" /usr/local/etc/rc.d/freeswitch
#chmod u-w,ugo+x /usr/local/etc/rc.d/freeswitch

#enable the services
echo 'freeswitch_enable="YES"' >> /etc/rc.conf
echo 'freeswitch_flags="-nonat"' >> /etc/rc.conf
echo 'freeswitch_username="www"' >> /etc/rc.conf
echo 'freeswitch_groupname="www"' >> /etc/rc.conf

