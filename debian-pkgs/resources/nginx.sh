#!/bin/sh

#send a message
echo "Install the web server\n"

#install dependencies
apt-get -y install ssl-cert nginx php5-cli php5-common php-apc php5-gd php-db php5-fpm php5-memcache php5-sqlite php5-imap php5-mcrypt php5-curl

#enable fusionpbx nginx config
cp resources/nginx/fusionpbx /etc/nginx/sites-available/fusionpbx
ln -s /etc/nginx/sites-available/fusionpbx /etc/nginx/sites-enabled/fusionpbx

#self signed certificate
cp -r /etc/ssl/private/ssl-cert-snakeoil.key /etc/ssl/private/nginx.key
cp -r /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/ssl/certs/nginx.crt

#remove the default site
rm /etc/nginx/sites-enabled/default

# Changing file upload size from 2M to upload_size
sed -i /etc/php5/fpm/php.ini -e "s#upload_max_filesize = 2M#upload_max_filesize = 25M#"

# Changing post_max_size limit from 8M to upload_size
sed -i /etc/php5/fpm/php.ini -e "s#post_max_size = 8M#post_max_size = 25M#"

#Adding users to needed groups
adduser www-data freeswitch
adduser www-data audio
adduser www-data dialout

#restart nginx
service nginx restart