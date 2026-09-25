#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh

#install monit
apt-get install -y monit

#make the monit shell script executable
chmod 755 monit/shell.sh

#copy the freeswitch monit config
cp monit/freeswitch /etc/monit/conf.d

#restart monit
service monit restart
