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
	#pkg install --yes php70 php70-phar php70-pgsql php70-pdo php70-pdo_pgsql php70-pdo_odbc php70-pdo_sqlite php70-json php70-gd 
	#pkg install --yes php70-imap php70-ldap php70-mcrypt php70-openssl php70-sockets php70-simplexml php70-xml php70-session
	pkg install --yes postgresql96-client-9.6.2 postgresql96-contrib-9.6.2 postgresql96-server-9.6.2 php71-7.1.3 
	pkg install --yes php71-phar php71-pdo php71-pdo_odbc php71-pdo_sqlite php71-json php71-gd php71-imap php71-ldap 
	pkg install --yes php71-mcrypt php71-openssl php71-sockets php71-simplexml php71-xml php71-session
	if [ ."$database_version" = ."9.3" ]; then
		pkg install --yes php71-pdo_pgsql php71-pgsql
	else
		cd /usr/ports/databases/php71-pdo_pgsql/ && make install clean BATCH=yes
		cd /usr/ports/databases/php71-pgsql && make install clean BATCH=yes
	fi
fi

#reset the current working directory
cd $cwd

#enable fusionpbx nginx config
mv /usr/local/etc/nginx/nginx.conf /usr/local/etc/nginx/nginx.conf-orig
cp nginx/nginx.conf /usr/local/etc/nginx
mkdir -p /usr/local/etc/nginx/conf.d
mkdir -p /usr/local/etc/nginx/sites-available/
mkdir -p /usr/local/etc/nginx/sites-enabled/
cp nginx/fusionpbx.conf /usr/local/etc/nginx/sites-available/fusionpbx
ln -s /usr/local/etc/nginx/sites-available/fusionpbx /usr/local/etc/nginx/sites-enabled/fusionpbx

#set the IP= address
common_name=$(ifconfig $interface_name | grep 'inet ' | awk '{print $2}')

#self signed certificate
openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
    -subj "/C=US/ST=Online/L=SelfSigned/O=FusionPBX/CN=$common_name" \
    -keyout /usr/local/etc/nginx/server.key -out /usr/local/etc/nginx/server.crt

#add the letsencrypt directory
mkdir -p /var/www/letsencrypt/

#restart php fpm and nginx
service php-fpm restart
service nginx restart

