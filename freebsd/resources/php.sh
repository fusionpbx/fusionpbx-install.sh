#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh

#send a message
verbose "Configuring PHP"

#update config if source is being used
if [ ."$php_version" = ."5" ]; then
        verbose "version 5.x"
        php_ini_file='/etc/php5/fpm/php.ini'
fi
if [ ."$php_version" = ."7" ]; then
        verbose "version 7.0"
        php_ini_file='/etc/php/7.0/fpm/php.ini'
fi
sed -i' ' -e 's#post_max_size = .*#post_max_size = 80M#g' $php_ini_file
sed -i' ' -e 's#upload_max_filesize = .*#upload_max_filesize = 80M#g' $php_ini_file

#restart php-fpm
service php-fpm restart
