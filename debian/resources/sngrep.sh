#!/bin/sh

#add sngrep
if [ ."$cpu_architecture" != ."arm" ]; then
	echo 'deb http://packages.irontec.com/debian jessie main' > /etc/apt/sources.list.d/sngrep.list
	wget http://packages.irontec.com/public.key -q -O - | apt-key add -
	apt-get update
	apt-get install sngrep
fi
