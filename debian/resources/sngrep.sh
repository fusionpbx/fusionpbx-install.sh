#!/bin/sh

#add sngrep
if [ ."$cpu_architecture" = ."arm" ]; then
	#source install
	apt-get install git autoconf automake gcc make libncurses5-dev libpcap-dev libssl-dev libpcre3-dev
	cd /usr/src/sngrep
	git clone https://github.com/irontec/sngrep
	./bootstrap.sh
	./configure
	make install
else
	#package install
	echo 'deb http://packages.irontec.com/debian jessie main' > /etc/apt/sources.list.d/sngrep.list
	wget http://packages.irontec.com/public.key -q -O - | apt-key add -
	apt-get update
	apt-get install sngrep
fi
