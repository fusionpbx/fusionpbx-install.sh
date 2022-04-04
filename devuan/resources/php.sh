#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh
. ./environment.sh

#send a message
verbose "Configuring PHP"

#set php version
#chimaera - bullseye
#beowolf - buster
if [ ."$os_codename" = ."beowolf" ]; then
      php_version=7.3
fi
if [ ."$os_codename" = ."chimaera" ]; then
      php_version=7.4
fi

#install dependencies
apt-get install -y nginx
if [ ."$php_version" = ."" ]; then
		apt-get install -y php php-cli php-fpm php-pgsql php-sqlite3 php-odbc php-curl php-imap php-xml php-gd
fi
if [ ."$php_version" = ."7.3" ]; then
		apt-get install -y php7.3 php7.3-cli php7.3-fpm php7.3-pgsql php7.3-sqlite3 php7.3-odbc php7.3-curl php7.3-imap php7.3-xml php7.3-gd php7.3-mbstring
fi
if [ ."$php_version" = ."7.4" ]; then
		apt-get install -y php7.4 php7.4-cli php7.4-dev php7.4-fpm php7.4-pgsql php7.4-sqlite3 php7.4-odbc php7.4-curl php7.4-imap php7.4-xml php7.4-gd php7.4-mbstring
fi

#update config if source is being used
if [ ."$php_version" = ."7.3" ]; then
        verbose "version 7.3"
        php_ini_file='/etc/php/7.3/fpm/php.ini'
fi
if [ ."$php_version" = ."7.4" ]; then
        verbose "version 7.4"
        php_ini_file='/etc/php/7.4/fpm/php.ini'
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
if [ ."$php_version" = ."7.3" ]; then
    /usr/sbin/service php7.3-fpm restart
fi
if [ ."$php_version" = ."7.4" ]; then
    /usr/sbin/service php7.4-fpm restart
fi
