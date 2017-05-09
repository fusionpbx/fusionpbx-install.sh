#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh
. ./environment.sh

#send a message
verbose "Installing Nginx"

#if [ ."$cpu_architecture" = ."arm" ]; then
        #9.x - */stretch/
        #8.x - */jessie/
#fi
if [ ."$php_version" = ."5" ]; then
        #verbose "Switching forcefully to php5* packages"
        which add-apt-repository || apt-get install -y software-properties-common
        #LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
        #LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php5-compat
        apt-get update
elif [ ."$os_name" = ."Ubuntu" ]; then
        #16.10.x - */yakkety/
        #16.04.x - */xenial/
        #14.04.x - */trusty/
        if [ ."$os_codename" = ."trusty" ]; then
                which add-apt-repository || apt-get install -y software-properties-common
                LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
                apt-get -q update
        fi
elif [ ."$cpu_architecture" = ."arm" ]; then
        #Pi2 and Pi3 Raspbian
        #Odroid
        if [ ."$os_codename" = ."jessie" ]; then
                echo "deb http://packages.moopi.uk/debian jessie main" > /etc/apt/sources.list.d/moopi.list
                wget -O - http://packages.moopi.uk/debian/moopi.gpg.key | apt-key add -
                apt-get -q update
        fi
else
        #9.x - */stretch/
        #8.x - */jessie/
        if [ ."$os_codename" = ."jessie" ]; then
                echo "deb http://packages.dotdeb.org $os_codename all" > /etc/apt/sources.list.d/dotdeb.list
                echo "deb-src http://packages.dotdeb.org $os_codename all" >> /etc/apt/sources.list.d/dotdeb.list
                wget -O - https://www.dotdeb.org/dotdeb.gpg | apt-key add -
                apt-get -q update
        fi
fi

#use php version 5 for arm
#if [ .$cpu_architecture = .'arm' ]; then
#        php_version=5
#fi

#install dependencies
apt-get install -y -q nginx
if [ ."$php_version" = ."5" ]; then
        apt-get install -y -q php5 php5-cli php5-fpm php5-pgsql php5-sqlite php5-odbc php5-curl php5-imap php5-mcrypt
fi
if [ ."$php_version" = ."7" ]; then
        apt-get install -y -q php7.0 php7.0-cli php7.0-fpm php7.0-pgsql php7.0-sqlite3 php7.0-odbc php7.0-curl php7.0-imap php7.0-mcrypt php7.0-xml
fi

#enable fusionpbx nginx config
cp nginx/fusionpbx /etc/nginx/sites-available/fusionpbx

#prepare socket name
if [ ."$php_version" = ."5" ]; then
        sed -i /etc/nginx/sites-available/fusionpbx -e 's#unix:.*;#unix:/var/run/php5-fpm.sock;#g'
fi
if [ ."$php_version" = ."7" ]; then
        sed -i /etc/nginx/sites-available/fusionpbx -e 's#unix:.*;#unix:/var/run/php/php7.0-fpm.sock;#g'
fi
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
