#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh
. ./environment.sh

#send a message
verbose "Installing the web server"

#change the version of php for debian stretch
if [ ."$os_codename" = ."stretch" ]; then
	php_version=7.0
fi

#if [ ."$cpu_architecture" = ."arm" ]; then
        #9.x - */stretch/
        #8.x - */jessie/
#fi
if [ ."$php_version" = ."5.6" ]; then
        #verbose "Switching forcefully to php5* packages"
        which add-apt-repository || apt-get install -y software-properties-common
        #LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
        #LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php5-compat
elif [ ."$os_name" = ."Ubuntu" ]; then
        #16.10.x - */yakkety/
        #16.04.x - */xenial/
        #14.04.x - */trusty/
        if [ ."$os_codename" = ."trusty" ]; then
                which add-apt-repository || apt-get install -y software-properties-common
                LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
        fi
elif [ ."$cpu_architecture" = ."arm" ]; then
	#Pi2 and Pi3 Raspbian
	#Odroid
	if [ ."$os_codename" = ."stretch" ]; then
	      php_version=7.2
	else
	      php_version=5.6
	fi
	apt-get -y install apt-transport-https lsb-release ca-certificates
	wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
	sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
else
        #9.x - */stretch/
        #8.x - */jessie/
        if [ ."$os_codename" = ."jessie" ]; then
                apt-get -y install apt-transport-https lsb-release ca-certificates
                wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
                sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
        fi
fi
apt-get update

#use php version 5.6 for arm
#if [ .$cpu_architecture = .'arm' ]; then
#        php_version=5.6
#fi

#install dependencies
apt-get install -y nginx
if [ ."$php_version" = ."5.6" ]; then
        apt-get install -y php5 php5-cli php5-fpm php5-pgsql php5-sqlite php5-odbc php5-curl php5-imap php5-mcrypt php5-gd
fi
if [ ."$php_version" = ."7.0" ]; then
        apt-get install -y php7.0 php7.0-cli php7.0-fpm php7.0-pgsql php7.0-sqlite3 php7.0-odbc php7.0-curl php7.0-imap php7.0-mcrypt php7.0-xml php7.0-gd
fi
if [ ."$php_version" = ."7.1" ]; then
        apt-get install -y php7.1 php7.1-cli php7.1-fpm php7.1-pgsql php7.1-sqlite3 php7.1-odbc php7.1-curl php7.1-imap php7.1-mcrypt php7.1-xml php7.1-gd
fi
if [ ."$php_version" = ."7.2" ]; then
        apt-get install -y php7.2 php7.2-cli php7.2-fpm php7.2-pgsql php7.2-sqlite3 php7.2-odbc php7.2-curl php7.2-imap php7.2-mcrypt php7.2-xml php7.2-gd
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
ln -s /etc/nginx/sites-available/fusionpbx /etc/nginx/sites-enabled/fusionpbx

#self signed certificate
ln -s /etc/ssl/private/ssl-cert-snakeoil.key /etc/ssl/private/nginx.key
ln -s /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/ssl/certs/nginx.crt

#remove the default site
rm /etc/nginx/sites-enabled/default

#update config if LetsEncrypt folder is unwanted
if [ .$letsencrypt_folder = .false ]; then
        sed -i '151,155d' /etc/nginx/sites-available/fusionpbx
fi

#add the letsencrypt directory
if [ .$letsencrypt_folder = .true ]; then
        mkdir -p /var/www/letsencrypt/
fi

#restart nginx
service nginx restart
