#!/bin/sh

#send a message
echo "Configure PHP"

#update config if source is being used
sed 's#post_max_size = .*#post_max_size = 32M#g' -i /etc/php5/fpm/php.ini

#restart php5-fpm
#systemd
/bin/systemctl restart php5-fpm

#init.d
#/usr/sbin/service php5-fpm restart
