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
 	#set the version of php
	if [ ."$os_codename" = ."bullseye" ]; then
		php_version=7.4
	fi
fi

#set the version of php
#if [ ."$os_codename" = ."bullseye" ]; then
#	php_version=7.4
#fi
if [ ."$os_codename" = ."buster" ]; then
	php_version=7.3
fi
if [ ."$os_codename" = ."stretch" ]; then
	php_version=7.1
fi
if [ ."$os_codename" = ."jessie" ]; then
	php_version=7.1
fi

#enable fusionpbx nginx config
cp nginx/fusionpbx /etc/nginx/sites-available/fusionpbx

#prepare socket name
if [ ."$php_version" = ."5.6" ]; then
        sed -i /etc/nginx/sites-available/fusionpbx -e 's#unix:.*;#unix:/var/run/php5-fpm.sock;#g'
fi
if [ ."$php_version" = ."7.0" ]; then
        sed -i /etc/nginx/sites-available/fusionpbx -e 's#unix:.*;#unix:/var/run/php/php7.0-fpm.sock;#g'
fi
if [ ."$php_version" = ."7.1" ]; then
        sed -i /etc/nginx/sites-available/fusionpbx -e 's#unix:.*;#unix:/var/run/php/php7.1-fpm.sock;#g'
fi
if [ ."$php_version" = ."7.2" ]; then
        sed -i /etc/nginx/sites-available/fusionpbx -e 's#unix:.*;#unix:/var/run/php/php7.2-fpm.sock;#g'
fi
if [ ."$php_version" = ."7.3" ]; then
        sed -i /etc/nginx/sites-available/fusionpbx -e 's#unix:.*;#unix:/var/run/php/php7.3-fpm.sock;#g'
fi
if [ ."$php_version" = ."7.4" ]; then
        sed -i /etc/nginx/sites-available/fusionpbx -e 's#unix:.*;#unix:/var/run/php/php7.4-fpm.sock;#g'
fi
if [ ."$php_version" = ."8.1" ]; then
        sed -i /etc/nginx/sites-available/fusionpbx -e 's#unix:.*;#unix:/var/run/php/php8.1-fpm.sock;#g'
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

#flush systemd cache
systemctl daemon-reload

#restart nginx
service nginx restart
