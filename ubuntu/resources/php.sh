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
	#24.04.x - /*noble/
        if [ ."$os_codename" = ."noble" ]; then
                echo "Ubuntu 24.04 LTS\n"
                which add-apt-repository || apt-get install -y software-properties-common
                LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
        fi
	#22.04.x - /*jammy/
        if [ ."$os_codename" = ."jammy" ]; then
                echo "Ubuntu 22.04 LTS\n"
                which add-apt-repository || apt-get install -y software-properties-common
                LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
        fi
	#20.04.x - /*bionic/
        if [ ."$os_codename" = ."focal" ]; then
                echo "Ubuntu 20.04 LTS\n"
                which add-apt-repository || apt-get install -y software-properties-common
                LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
        fi
	#18.04.x - /*bionic/
        if [ ."$os_codename" = ."bionic" ]; then
                echo "Ubuntu 18.04 LTS\n"
		php_version=7.2
        fi
        #16.10.x - */yakkety/
        #16.04.x - */xenial/
        #14.04.x - */trusty/
        if [ ."$os_codename" = ."trusty" ]; then
                which add-apt-repository || apt-get install -y software-properties-common
                LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
        fi
elif [ ."$cpu_architecture" = ."arm" ]; then
	echo "arm"
fi
apt-get update -y

#install dependencies
apt-get install -y nginx
if [ ."$php_version" = ."5.6" ]; then
        apt-get install -y php5 php5-cli php5-fpm php5-pgsql php5-sqlite php5-odbc php5-curl php5-imap php5-gd
fi
if [ ."$php_version" = ."7.0" ]; then
        apt-get install -y php7.0 php7.0-cli php7.0-fpm php7.0-pgsql php7.0-sqlite3 php7.0-odbc php7.0-curl php7.0-imap php7.0-xml php7.0-gd php7.0-mbstring
fi
if [ ."$php_version" = ."7.1" ]; then
        apt-get install -y php7.1 php7.1-cli php7.1-fpm php7.1-pgsql php7.1-sqlite3 php7.1-odbc php7.1-curl php7.1-imap php7.1-xml php7.1-gd php7.1-mbstring
fi
if [ ."$php_version" = ."7.2" ]; then
        apt-get install -y php7.2 php7.2-cli php7.2-fpm php7.2-pgsql php7.2-sqlite3 php7.2-odbc php7.2-curl php7.2-imap php7.2-xml php7.2-gd php7.2-mbstring
fi
if [ ."$php_version" = ."7.4" ]; then
        apt-get install -y php7.4 php7.4-cli php7.4-fpm php7.4-pgsql php7.4-sqlite3 php7.4-odbc php7.4-curl php7.4-imap php7.4-xml php7.4-gd php7.4-mbstring
fi
if [ ."$php_version" = ."8.1" ]; then
        apt-get install -y php8.1 php8.1-cli php8.1-fpm php8.1-pgsql php8.1-sqlite3 php8.1-odbc php8.1-curl php8.1-imap php8.1-xml php8.1-gd php8.1-mbstring
fi
if [ ."$php_version" = ."8.2" ]; then
        apt-get install -y php8.2 php8.2-cli php8.2-fpm php8.2-pgsql php8.2-sqlite3 php8.2-odbc php8.2-curl php8.2-imap php8.2-xml php8.2-gd php8.2-mbstring
fi
if [ ."$php_version" = ."8.3" ]; then
        apt-get install -y php8.3 php8.3-cli php8.3-fpm php8.3-pgsql php8.3-sqlite3 php8.3-odbc php8.3-curl php8.3-imap php8.3-xml php8.3-gd php8.3-mbstring
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
if [ ."$php_version" = ."7.4" ]; then
        verbose "version 7.4"
        php_ini_file='/etc/php/7.4/fpm/php.ini'
fi
if [ ."$php_version" = ."8.1" ]; then
        verbose "version 8.1"
        php_ini_file='/etc/php/8.1/fpm/php.ini'
fi
if [ ."$php_version" = ."8.2" ]; then
        verbose "version 8.2"
        php_ini_file='/etc/php/8.2/fpm/php.ini'
fi
if [ ."$php_version" = ."8.3" ]; then
        verbose "version 8.3"
        php_ini_file='/etc/php/8.3/fpm/php.ini'
fi
sed 's#post_max_size = .*#post_max_size = 80M#g' -i $php_ini_file
sed 's#upload_max_filesize = .*#upload_max_filesize = 80M#g' -i $php_ini_file
sed 's#;max_input_vars = .*#max_input_vars = 8000#g' -i $php_ini_file
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
if [ ."$php_version" = ."7.4" ]; then
        systemctl restart php7.4-fpm
fi
if [ ."$php_version" = ."8.1" ]; then
        systemctl restart php8.1-fpm
fi
if [ ."$php_version" = ."8.2" ]; then
        systemctl restart php8.2-fpm
fi
if [ ."$php_version" = ."8.3" ]; then
        systemctl restart php8.3-fpm
fi
#init.d
#/usr/sbin/service php5-fpm restart
#/usr/sbin/service php7.0-fpm restart
