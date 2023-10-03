#!/bin/sh

#includes
. ./config.sh
. ./colors.sh

#enable php fpm
echo 'php_fpm_enable="YES"' >> /etc/rc.conf

#set the default version of postgres
echo "DEFAULT_VERSIONS+=pgsql=$database_version" >> /etc/make.conf
echo "DEFAULT_VERSIONS+=ssl=openssl" >> /etc/make.conf

#install dependencies
if [ ."$php_version" = ."8.0" ]; then
	pkg install --yes php80 php80-phar php80-pdo php80-pdo_odbc php80-pdo_sqlite php80-gd php80-imap \
		php80-ldap php80-sockets php80-simplexml php80-xml php80-session php80-iconv php80-zlib \
		php80-filter postgresql13-client php80-pdo_pgsql php80-pgsql php80-curl php80-mbstring
fi
if [ ."$php_version" = ."8.1" ]; then
	pkg install --yes php81 php81-phar php81-pdo php81-pdo_odbc php81-pdo_sqlite php81-gd php81-imap \
		php81-ldap php81-sockets php81-simplexml php81-xml php81-session php81-iconv php81-zlib \
		php81-filter postgresql13-client php81-pdo_pgsql php81-pgsql php81-curl php81-mbstring
fi
if [ ."$php_version" = ."8.2" ]; then
	pkg install --yes php82 php82-phar php82-pdo php82-pdo_odbc php82-pdo_sqlite php82-gd php82-imap \
		php82-ldap php82-sockets php82-simplexml php82-xml php82-session php82-iconv php82-zlib \
		php82-filter postgresql13-client php82-pdo_pgsql php82-pgsql php82-curl php82-mbstring
fi
if [ ."$php_version" = ."8.3" ]; then
	pkg install --yes php83 php83-phar php83-pdo php83-pdo_odbc php83-pdo_sqlite php83-gd php83-imap \
		php83-ldap php83-sockets php83-simplexml php83-xml php83-session php83-iconv php83-zlib \
		php83-filter postgresql13-client php83-pdo_pgsql php83-pgsql php83-curl php83-mbstring
fi
#send a message
verbose "Configuring PHP"

#update config if source is being used
cp /usr/local/etc/php.ini-production /usr/local/etc/php.ini
sed -i' ' -e s:'post_max_size = .*:post_max_size = 80M:g' /usr/local/etc/php.ini
sed -i' ' -e s:'upload_max_filesize = .*:upload_max_filesize = 80M:g' /usr/local/etc/php.ini
sed -i' ' -e s:'; max_input_vars = .*:max_input_vars = 8000:g' /usr/local/etc/php.ini

#restart php-fpm
service php-fpm restart
