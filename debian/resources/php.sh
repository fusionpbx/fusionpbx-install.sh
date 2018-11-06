#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh

#send a message
verbose "Configuring PHP"

#change the version of php for debian stretch
if [ ."$os_codename" = ."stretch" ]; then
       if [ ."$cpu_architecture" = ."arm" ]; then
              php_version=7.2
       else
              php_version=7.0
       fi 
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
sed 's#post_max_size = .*#post_max_size = 80M#g' -i $php_ini_file
sed 's#upload_max_filesize = .*#upload_max_filesize = 80M#g' -i $php_ini_file

#restart php-fpm
#systemd
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

#init.d
#/usr/sbin/service php5-fpm restart
#/usr/sbin/service php7.0-fpm restart
