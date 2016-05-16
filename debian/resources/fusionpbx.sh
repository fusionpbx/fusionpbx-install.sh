#!/bin/sh

#send a message
echo "Install FusionPBX"

#install dependencies
apt-get install -y --force-yes vim git dbus haveged ssl-cert
apt-get install -y --force-yes ghostscript libtiff5-dev libtiff-tools

#get the source code
git clone https://github.com/fusionpbx/fusionpbx.git /var/www/fusionpbx
chown -R www-data:www-data /var/www/fusionpbx
