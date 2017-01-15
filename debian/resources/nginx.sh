#!/bin/sh

#send a message
echo "Install the web server\n"

#install dependencies
apt-get install -y --force-yes nginx php5 php5-cli php5-fpm php5-pgsql php5-sqlite php5-odbc php5-curl php5-imap php5-mcrypt

#enable fusionpbx nginx config
cp resources/nginx/fusionpbx /etc/nginx/sites-available/fusionpbx
ln -s /etc/nginx/sites-available/fusionpbx /etc/nginx/sites-enabled/fusionpbx

#self signed certificate
ln -s /etc/ssl/private/ssl-cert-snakeoil.key /etc/ssl/private/nginx.key
ln -s /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/ssl/certs/nginx.crt

#remove the default site
rm /etc/nginx/sites-enabled/default

#restart nginx
service nginx restart
