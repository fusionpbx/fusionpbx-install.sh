#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh

#send a message
verbose "Installing the web server"

#install nginx
pkg install --yes nginx

#enable nginx
echo 'nginx_enable="YES"' >> /etc/rc.conf
if [ ."$php_version" = ."5" ]; then
	echo 'php5.6-fpm="YES"' >> /etc/rc.conf
fi
if [ ."$php_version" = ."7" ]; then
	echo 'php7.0-fpm="YES"' >> /etc/rc.conf
fi

#install dependencies
if [ ."$php_version" = ."5" ]; then
	pkg install --yes php56 php56-phar php56-pgsql php56-pdo php56-pdo_pgsql php56-pdo_odbc php56-pdo_sqlite php56-json php56-gd
	pkg install --yes php56-imap php56-ldap php56-mcrypt php56-openssl php56-sockets php56-simplexml php56-xml php56-session
fi
if [ ."$php_version" = ."7" ]; then
	pkg install --yes php70 php70-phar php70-pgsql php70-pdo php70-pdo_pgsql php70-pdo_odbc php70-pdo_sqlite php70-json php70-gd 
	pkg install --yes php70-imap php70-ldap php70-mcrypt php70-openssl php70-sockets php70-simplexml php70-xml php70-session
fi

#update the list of executables in the path
rehash

#enable fusionpbx nginx config
mv /usr/local/etc/nginx/nginx.conf /usr/local/etc/nginx/nginx.conf-orig
cp nginx/nginx.conf /usr/local/etc/nginx
mkdir -p /usr/local/etc/nginx/conf.d
mkdir -p /usr/local/etc/nginx/sites-available/
mkdir -p /usr/local/etc/nginx/sites-enabled/
cp nginx/fusionpbx.conf /usr/local/etc/nginx/sites-available/fusionpbx
ln -s /usr/local/etc/nginx/sites-available/fusionpbx /usr/local/etc/nginx/sites-enabled/fusionpbx

#self signed certificate
#ln -s /etc/ssl/private/ssl-cert-snakeoil.key /etc/ssl/private/nginx.key
#ln -s /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/ssl/certs/nginx.crt

#add the letsencrypt directory
mkdir -p /var/www/letsencrypt/

#restart php fpm and nginx
service php-fpm restart
service nginx restart

