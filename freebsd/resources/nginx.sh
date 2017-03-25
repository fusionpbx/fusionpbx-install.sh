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
echo 'php_fpm_enable="YES"' >> /etc/rc.conf

#install dependencies
if [ ."$php_version" = ."5" ]; then
	#pkg install php57
fi
if [ ."$php_version" = ."7" ]; then
	pkg install --yes php70 php70-phar php70-pgsql php70-pdo php70-pdo_pgsql php70-pdo_odbc php70-pdo_sqlite php70-json php70-gd 
php70-imap php70-ldap php70-mcrypt php70-openssl php70-sockets php70-simplexml php70-xml php70-session
fi

#enable fusionpbx nginx config
#cp nginx/fusionpbx.conf /usr/local/etc/nginx/conf.d/fusionpbx

#self signed certificate
#ln -s /etc/ssl/private/ssl-cert-snakeoil.key /etc/ssl/private/nginx.key
#ln -s /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/ssl/certs/nginx.crt

#remove the default site
#rm /etc/nginx/sites-enabled/default

#add the letsencrypt directory
mkdir -p /var/www/letsencrypt/

#restart php fpm and nginx
service php-fpm restart
service nginx restart


