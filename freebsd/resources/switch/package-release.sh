#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ../config.sh

#set the current working directory
cwd=$(pwd)

#send a message
echo "Installing the FreeSWITCH package"

#install the package
pkg install freeswitch

#set the original working directory
cd $cwd

#configure system service
ln -s /usr/local/freeswitch/bin/fs_cli /usr/bin/fs_cli
cp "$(dirname $0)/rc.d.freeswitch /usr/local/etc/rc.d/freeswitch
chmod u-w,ugo+x /usr/local/etc/rc.d/freeswitch

#enable the service
echo 'freeswitch_enable="YES"' >> /etc/rc.conf
echo 'freeswitch_flags="-nc -nonat -u www -g www"' >> /etc/rc.conf

#start the service
service freeswitch restart
