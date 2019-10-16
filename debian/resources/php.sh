#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh
. ./environment.sh

#send a message
verbose "Configuring PHP"

#add the repository
if [ ."$os_name" = ."Ubuntu" ]; then
        #16.10.x - */yakkety/
        #16.04.x - */xenial/
        #14.04.x - */trusty/
        if [ ."$os_codename" = ."trusty" ]; then
                which add-apt-repository || apt-get install -y software-properties-common
                LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
        fi
elif [ ."$cpu_architecture" = ."arm" ]; then
	#Pi2 and Pi3 Raspbian, #Odroid
	#if [ ."$os_codename" = ."stretch" ]; then
	#      php_version=7.0
	#fi
	if [ ."$os_codename" = ."buster" ]; then
	      php_version=7.3
	fi
else
        #10.x - buster
	#9.x  - stretch
        #8.x  - jessie
	apt-get -y install apt-transport-https lsb-release ca-certificates
	if [ ."$os_codename" = ."jessie" ]; then
		wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
		sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
	fi
	if [ ."$os_codename" = ."stretch" ]; then
		wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
		sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
	fi
	if [ ."$os_codename" = ."buster" ]; then
	      php_version=7.3
	fi
fi
apt-get update -y

#install dependencies
apt-get install -y nginx
if [ ."$php_version" = ."" ]; then
        apt-get install -y php php-cli php-fpm php-pgsql php-sqlite3 php-odbc php-curl php-imap php-xml php-gd
fi
if [ ."$php_version" = ."5.6" ]; then
        apt-get install -y php5 php5-cli php5-fpm php5-pgsql php5-sqlite php5-odbc php5-curl php5-imap php5-gd
fi
if [ ."$php_version" = ."7.0" ]; then
        apt-get install -y php7.0 php7.0-cli php7.0-fpm php7.0-pgsql php7.0-sqlite3 php7.0-odbc php7.0-curl php7.0-imap php7.0-xml php7.0-gd
fi
if [ ."$php_version" = ."7.1" ]; then
        apt-get install -y php7.1 php7.1-cli php7.1-fpm php7.1-pgsql php7.1-sqlite3 php7.1-odbc php7.1-curl php7.1-imap php7.1-xml php7.1-gd
fi
if [ ."$php_version" = ."7.2" ]; then
        apt-get install -y php7.2 php7.2-cli php7.2-fpm php7.2-pgsql php7.2-sqlite3 php7.2-odbc php7.2-curl php7.2-imap php7.2-xml php7.2-gd
fi
if [ ."$php_version" = ."7.3" ]; then
        apt-get install -y php7.3 php7.3-cli php7.3-fpm php7.3-pgsql php7.3-sqlite3 php7.3-odbc php7.3-curl php7.3-imap php7.3-xml php7.3-gd
fi

#update config if source is being used
if [ ."$php_version" = ."5" ]; then
        verbose "version 5.x"
        php_ini_file='/etc/php5/fpm/php.ini'
fi
if [ ."$php_version" = ."7.0" ]; then
        verbose "version 7.0"
        php_ini_file='/etc/php/7.0/fpm/php.ini'
fi
if [ ."$php_version" = ."7.1" ]; then
        verbose "version 7.1"
        php_ini_file='/etc/php/7.1/fpm/php.ini'
fi
if [ ."$php_version" = ."7.2" ]; then
        verbose "version 7.2"
        php_ini_file='/etc/php/7.2/fpm/php.ini'
fi
if [ ."$php_version" = ."7.3" ]; then
        verbose "version 7.3"
        php_ini_file='/etc/php/7.3/fpm/php.ini'
fi
sed 's#post_max_size = .*#post_max_size = 80M#g' -i $php_ini_file
sed 's#upload_max_filesize = .*#upload_max_filesize = 80M#g' -i $php_ini_file
sed 's#; max_input_vars = .*#max_input_vars = 8000#g' -i $php_ini_file

#install ioncube
if [ .$cpu_architecture = .'x86' ]; then
	. ./ioncube.sh
fi

#restart php-fpm
systemctl daemon-reload
if [ ."$php_version" = ."5.6" ]; then
        systemctl restart php5-fpm
fi
if [ ."$php_version" = ."7.0" ]; then
        systemctl restart php7.0-fpm
fi
if [ ."$php_version" = ."7.1" ]; then
        systemctl restart php7.1-fpm
fi
if [ ."$php_version" = ."7.2" ]; then
        systemctl restart php7.2-fpm
fi
if [ ."$php_version" = ."7.3" ]; then
        systemctl restart php7.3-fpm
fi

#init.d
#/usr/sbin/service php5-fpm restart
#/usr/sbin/service php7.0-fpm restart
