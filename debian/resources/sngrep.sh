#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh
. ./environment.sh

#add sngrep

#package install
if [ ."$os_codename" = ."jessie" ]; then
	echo "deb http://packages.irontec.com/debian $os_codename main" > /etc/apt/sources.list.d/sngrep.list
	wget http://packages.irontec.com/public.key -q -O - | apt-key add -
	apt-get update
fi
apt-get install -y sngrep
