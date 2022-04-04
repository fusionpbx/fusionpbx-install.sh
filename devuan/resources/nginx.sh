#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh
. ./environment.sh

#send a message
verbose "Installing the web server"

#change the version of php for arm
if [ ."$cpu_architecture" = ."arm" ]; then
	#Pi2 and Pi3 Raspbian
	#Odroid
	if [ ."$os_codename" = ."stretch" ]; then
	      php_version=7.2
	else
	      php_version=5.6
	fi
fi

#set the version of php
if [ ."$os_codename" = ."chimaera" ]; then
	php_version=7.4
fi
if [ ."$os_codename" = ."beowulf" ]; then
	php_version=7.3
fi

#enable fusionpbx nginx config
cp nginx/fusionpbx /etc/nginx/sites-available/fusionpbx

#prepare socket name
if [ ."$php_version" = ."7.3" ]; then
        sed -i /etc/nginx/sites-available/fusionpbx -e 's#unix:.*;#unix:/var/run/php/php7.3-fpm.sock;#g'
fi
if [ ."$php_version" = ."7.4" ]; then
        sed -i /etc/nginx/sites-available/fusionpbx -e 's#unix:.*;#unix:/var/run/php/php7.4-fpm.sock;#g'
fi
ln -s /etc/nginx/sites-available/fusionpbx /etc/nginx/sites-enabled/fusionpbx

#self signed certificate
ln -s /etc/ssl/private/ssl-cert-snakeoil.key /etc/ssl/private/nginx.key
ln -s /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/ssl/certs/nginx.crt

#remove the default site
rm /etc/nginx/sites-enabled/default

#update config if LetsEncrypt folder is unwanted
# if [ .$letsencrypt_folder = .false ]; then
#         sed -i '151,155d' /etc/nginx/sites-available/fusionpbx
# fi

#add the letsencrypt directory
if [ .$letsencrypt_folder = .true ]; then
        mkdir -p /var/www/letsencrypt/
fi

#restart nginx
/usr/sbin/service nginx restart
