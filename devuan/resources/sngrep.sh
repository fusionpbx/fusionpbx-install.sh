#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh
. ./environment.sh

#add sngrep
if [ ."$cpu_architecture" = ."arm" ]; then
	#source install
	apt-get -q -y install git autoconf automake gcc make libncurses5-dev libpcap-dev libssl-dev libpcre3-dev
	cd /usr/src && git clone https://github.com/irontec/sngrep
	cd /usr/src/sngrep && ./bootstrap.sh
	cd /usr/src/sngrep && ./configure
	cd /usr/src/sngrep && make install
else
	#package install
	echo 'deb http://packages.irontec.com/debian jessie main' > /etc/apt/sources.list.d/sngrep.list
	wget http://packages.irontec.com/public.key -q -O - | apt-key add -
	apt-get -q update
	apt-get -y -q install -y --force-yes sngrep
fi
