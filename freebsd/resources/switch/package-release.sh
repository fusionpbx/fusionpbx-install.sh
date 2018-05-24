#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ../config.sh

#install dependencies
pkg install --yes tiff memcached

#set the current working directory
cwd=$(pwd)

#send a message
echo "Installing the FreeSWITCH package"

#get the package
cd /usr/src && fetch https://www.fusionpbx.com/downloads/freebsd11/freeswitch-pgsql10-1.6.19_2.txz

#install the package
#pkg install --yes freeswitch
pkg install --yes /usr/src/freeswitch-pgsql10-1.6.19_2.txz

#set the original working directory
cd $cwd

#configure system service
#cp "$(dirname $0)/rc.d.freeswitch" /usr/local/etc/rc.d/freeswitch
#chmod u-w,ugo+x /usr/local/etc/rc.d/freeswitch

#enable the services
echo 'memcached_enable="YES"' >> /etc/rc.conf
echo 'freeswitch_enable="YES"' >> /etc/rc.conf
echo 'freeswitch_flags="-nonat"' >> /etc/rc.conf
echo 'freeswitch_user="www"' >> /etc/rc.conf
echo 'freeswitch_group="www"' >> /etc/rc.conf

#start the service
service memcached start
