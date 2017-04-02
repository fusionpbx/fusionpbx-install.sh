#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh

#set the current working directory
cwd=$(pwd)

#send a message
verbose "Installing the web server"

#install nginx
pkg install --yes nginx

#enable nginx
echo 'nginx_enable="YES"' >> /etc/rc.conf
echo 'php_fpm_enable="YES"' >> /etc/rc.conf

#set the default version of postgres
echo "DEFAULT_VERSIONS+=pgsql=$database_version" >> /etc/make.conf
echo "DEFAULT_VERSIONS+=ssl=openssl" >> /etc/make.conf

#install dependencies
if [ ."$php_version" = ."5" ]; then
	pkg install --yes php56 php56-phar php56-pgsql php56-pdo php56-pdo_pgsql php56-pdo_odbc php56-pdo_sqlite php56-json php56-gd
	pkg install --yes php56-imap php56-ldap php56-mcrypt php56-openssl php56-sockets php56-simplexml php56-xml php56-session
fi
if [ ."$php_version" = ."7" ]; then
	pkg install --yes php70 php70-phar php70-pgsql php70-pdo php70-pdo_pgsql php70-pdo_odbc php70-pdo_sqlite php70-json php70-gd 
	pkg install --yes php70-imap php70-ldap php70-mcrypt php70-openssl php70-sockets php70-simplexml php70-xml php70-session

	#portsnap fetch update
	#cd /usr/ports/lang/php70/ && make install clean BATCH=yes
	#cd /usr/ports/archivers/php70-phar/ && make install clean BATCH=yes
	#cd /usr/ports/databases/php70-pgsql/ && make install clean BATCH=yes
	#cd /usr/ports/databases/php70-pdo/ && make install clean BATCH=yes
	#cd /usr/ports/databases/php70-pdo_pgsql/ && make install clean BATCH=yes
	#cd /usr/ports/databases/php70-pdo_odbc/ && make install clean BATCH=yes
	#cd /usr/ports/databases/php70-pdo_sqlite/ && make install clean BATCH=yes
	#cd /usr/ports/devel/php70-json/ && make install clean BATCH=yes
	#cd /usr/ports/graphics/php70-gd/ && make install clean BATCH=yes
	#cd /usr/ports/mail/php70-imap/ && make install clean BATCH=yes
	#cd /usr/ports/net/php70-ldap/ && make install clean BATCH=yes
	#cd /usr/ports/security/php70-mcrypt/ && make install clean BATCH=yes
	#cd /usr/ports/security/php70-openssl/ && make install clean BATCH=yes
	#cd /usr/ports/net/php70-sockets/ && make install clean BATCH=yes
	#cd /usr/ports/textproc/php70-simplexml/ && make install clean BATCH=yes
	#cd /usr/ports/textproc/php70-xml/ && make install clean BATCH=yes
	#cd /usr/ports/www/php70-session/ && make install clean BATCH=yes
fi

#reset the current working directory
cd $cwd

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

