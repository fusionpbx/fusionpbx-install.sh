#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh

#send a message
verbose "Installing the web server"

#install dependencies
yum -y install nginx

#setup nginx
mkdir -p /etc/nginx/sites-available
mkdir -p /etc/nginx/sites-enabled

#enable fusionpbx nginx config
cp ./nginx/fusionpbx /etc/nginx/sites-available/fusionpbx.conf
ln -s /etc/nginx/sites-available/fusionpbx.conf /etc/nginx/sites-enabled/fusionpbx.conf
awk '/server *{/ {c=1 ; next} c && /{/{c++} c && /}/{c--;next} !c' /etc/nginx/nginx.conf > /etc/nginx/nginx.tmp && mv -f /etc/nginx/nginx.tmp /etc/nginx/nginx.conf && rm -f /etc/nginx/nginx.tmp
sed -i '/include \/etc\/nginx\/conf\.d\/\*\.conf\;/a \    include \/etc\/nginx\/sites-enabled\/\*\.conf\;' /etc/nginx/nginx.conf

#set the log permissions
chmod -R 664 /var/log/nginx/

#send a message
verbose "nginx installed"
