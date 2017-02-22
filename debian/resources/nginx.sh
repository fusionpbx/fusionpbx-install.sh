#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

. ./colors.sh
. ./arguments.sh

#send a message
verbose "Installing the web server"

arch=$(uname -m)
real_os=$(lsb_release -is)
codename=$(lsb_release -cs)
if [ $real_os = 'Ubuntu' ]; then
        #16.10.x - */yakkety/
        #16.04.x - */xenial/
        #14.04.x - */trusty/
        if [ $codename = 'trusty' ]; then
                LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
        fi
else
        #9.x - */stretch/
        #8.x - */jessie/
        if [ $codename = 'jessie' ]; then
                echo "deb http://packages.dotdeb.org $codename all" > /etc/apt/sources.list.d/dotdeb.list
                echo "deb-src http://packages.dotdeb.org $codename all" >> /etc/apt/sources.list.d/dotdeb.list
                wget -O - https://www.dotdeb.org/dotdeb.gpg | apt-key add -
        fi
fi
apt-get update

#install dependencies
apt-get install -y nginx php7.0 php7.0-cli php7.0-fpm php7.0-pgsql php7.0-sqlite3 php7.0-odbc php7.0-curl php7.0-imap php7.0-mcrypt php7.0-xml

#enable fusionpbx nginx config
cp nginx/fusionpbx /etc/nginx/sites-available/fusionpbx
ln -s /etc/nginx/sites-available/fusionpbx /etc/nginx/sites-enabled/fusionpbx

#self signed certificate
ln -s /etc/ssl/private/ssl-cert-snakeoil.key /etc/ssl/private/nginx.key
ln -s /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/ssl/certs/nginx.crt

#remove the default site
rm /etc/nginx/sites-enabled/default

#add the letsencrypt directory
mkdir -p /var/www/letsencrypt/

#restart nginx
service nginx restart
