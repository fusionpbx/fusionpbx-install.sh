#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

. ./colors.sh
. ./arguments.sh

verbose "Configuring php/nginx/php-fpm and permissions"

TIMEZ=$(timedatectl | grep 'Time zone' | awk '{ print $3 }')

sed -i 's/user nginx/user freeswitch daemon/g' /etc/nginx/nginx.conf
chown -Rf freeswitch:daemon /var/lib/nginx
sed -ie "s#;date.timezone =#date.timezone = $TIMEZ#g" /etc/php.ini
sed -ie 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php.ini
sed -ie "s|listen = 127.0.0.1:9000|listen = /var/run/php-fpm/php-fpm.sock|g" /etc/php-fpm.d/www.conf
sed -ie 's/;listen.owner = nobody/listen.owner = nobody/g' /etc/php-fpm.d/www.conf
sed -ie 's/;listen.group = nobody/listen.group = nobody/g' /etc/php-fpm.d/www.conf
sed -ie 's/user = apache/user = freeswitch/g' /etc/php-fpm.d/www.conf
sed -ie 's/group = apache/group = daemon/g' /etc/php-fpm.d/www.conf
mkdir -p /var/lib/php/session
chown -R freeswitch:daemon /var/lib/php/session
chmod -Rf 700 /var/lib/php/session

#update config if source is being used
#sed -ie 's/post_max_size = .*/post_max_size = 80M/g' /etc/php.ini
#sed -ie 's/upload_max_filesize = .*/upload_max_filesize = 80M/g' /etc/php.ini

chown -R freeswitch.daemon /etc/freeswitch /var/lib/freeswitch /var/log/freeswitch /usr/share/freeswitch /var/www/fusionpbx
find /etc/freeswitch -type d -exec chmod 770 {} \;
find /var/lib/freeswitch -type d -exec chmod 770 {} \;
find /var/log/freeswitch -type d -exec chmod 770 {} \;
find /usr/share/freeswitch -type d -exec chmod 770 {} \;
find /var/www/fusionpbx -type d -exec chmod 770 {} \;
find /etc/freeswitch -type f -exec chmod 664 {} \;
find /var/lib/freeswitch -type f -exec chmod 664 {} \;
find /var/log/freeswitch -type f -exec chmod 664 {} \;
find /usr/share/freeswitch -type f -exec chmod 664 {} \;
find /var/www/fusionpbx -type f -exec chmod 664 {} \;

verbose "php/nginx/php-fpm and permissions configured"