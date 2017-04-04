#!/bin/sh

#upgrade the packages
apt-get update && apt-get upgrade -y --force-yes

#install git
apt-get install -y --force-yes git

#get the install script
cd /usr/src && git clone https://github.com/fusionpbx/fusionpbx-install.sh.git

#change the working directory
cd /usr/src/fusionpbx-install.sh/debian
