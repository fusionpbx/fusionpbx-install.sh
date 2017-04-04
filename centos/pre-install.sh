#!/bin/sh

#install git
yum install git

#get the install script
cd /usr/src && git clone https://github.com/fusionpbx/fusionpbx-install.sh.git
