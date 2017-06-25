#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh

#install monit
pkg install --yes monit

#copy the monitor file
cp /usr/local/etc/monitrc.sample /usr/local/etc/monitrc

#make the monit.d directory
mkdir /usr/local/etc/monit.d

#add the include for monit.d
echo 'include /usr/local/etc/monit.d/*' >> /usr/local/etc/monitrc

#set root only permissions
chmod 600 /usr/local/etc/monitrc
chmod 600 /usr/local/etc/monit.d

#enable monit	
echo 'monit_enable="YES"' >> /etc/rc.conf

#monitor freeswitch
cat > /usr/local/etc/monit.d/freeswitch <<EOL
check process freeswitch with pidfile /usr/local/freeswitch/run/freeswitch.pid
start program = "/usr/sbin/service freeswitch start"
stop program  = "/usr/sbin/service freeswitch stop"
EOL

#set root only permissions                
chmod 600 /usr/local/etc/monitrc
chmod 600 /usr/local/etc/monit.d

#start monit
service monit start

