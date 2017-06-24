#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh

#install php
. ./php.sh

#send a message
verbose "Installing the web server"

#install nginx
pkg install --yes nginx

#enable nginx
echo 'nginx_enable="YES"' >> /etc/rc.conf

#enable fusionpbx nginx config
mv /usr/local/etc/nginx/nginx.conf /usr/local/etc/nginx/nginx.conf-orig
cp nginx/nginx.conf /usr/local/etc/nginx
mkdir -p /usr/local/etc/nginx/conf.d
mkdir -p /usr/local/etc/nginx/sites-available/
mkdir -p /usr/local/etc/nginx/sites-enabled/
cp nginx/fusionpbx.conf /usr/local/etc/nginx/sites-available/fusionpbx
ln -s /usr/local/etc/nginx/sites-available/fusionpbx /usr/local/etc/nginx/sites-enabled/fusionpbx

#get the primary interface name
if [ .$interface_name = .'auto' ]; then
	interface_name=$(ifconfig -l | awk '{print $1}')
	if [ .$interface_name = .'lo0' ]; then
		interface_name=$(ifconfig -l | awk '{print $2}')
	fi
fi

#get the ip address
local_ip_v4=$(ifconfig $interface_name | grep 'inet ' | awk '{print $2}')

#set the IP= address
common_name=$local_ip_v4

#self signed certificate
/usr/bin/openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
    -subj "/C=US/ST=Online/L=SelfSigned/O=FusionPBX/CN=$common_name" \
    -keyout /usr/local/etc/nginx/server.key -out /usr/local/etc/nginx/server.crt

#add the letsencrypt directory
mkdir -p /var/www/letsencrypt/

#restart php fpm and nginx
service php-fpm restart
service nginx restart

