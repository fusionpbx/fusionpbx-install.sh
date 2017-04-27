#!/bin/sh

#upgrade the packages
apt-get -q update && apt-get upgrade -y

#install git
apt-get install -y git

#get the install script
cd /usr/src && git clone https://github.com/fusionpbx/fusionpbx-install.sh.git

#change the working directory
cd /usr/src/fusionpbx-install.sh/devuan
