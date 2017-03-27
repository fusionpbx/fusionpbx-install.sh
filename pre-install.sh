#!/bin/sh

#upgrade the packages
apt-get update && apt-get upgrade -y --force-yes

#install git
apt-get install -y --force-yes git

#prepare dir
if [ ! -d /usr/src ]; then
	mkdir -vp /usr/src
fi

#get the install script
cd /usr/src && git clone https://github.com/fusionpbx/fusionpbx-install.sh.git
