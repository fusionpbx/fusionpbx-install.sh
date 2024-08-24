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
if [ ."$php_version" = ."7.3" ]; then
	pkg install --yes php73 php73-phar php73-pdo php73-pdo_odbc php73-pdo_sqlite php73-json php73-gd php73-imap
	pkg install --yes php73-ldap php73-openssl php73-sockets php73-simplexml php73-xml php73-session php73-iconv
	pkg install --yes php73-zlib php73-filter php73-pdo_pgsql php73-pgsql php73-curl php73-mbstring
fi
if [ ."$php_version" = ."7.4" ]; then
	pkg install --yes php74 php74-phar php74-pdo php74-pdo_odbc php74-pdo_sqlite php74-json php74-gd php74-imap
	pkg install --yes php74-ldap php74-openssl php74-sockets php74-simplexml php74-xml php74-session php74-iconv
	pkg install --yes php74-zlib php74-filter php74-pdo_pgsql php74-pgsql php74-curl php74-mbstring
	pkg install --yes php74-pdo_pgsql php74-pgsql
fi
if [ ."$php_version" = ."8.0" ]; then
	pkg install --yes php80 php80-phar php80-pdo php80-pdo_odbc php80-pdo_sqlite php80-gd php80-imap
	pkg install --yes php80-ldap php80-sockets php80-simplexml php80-xml php80-session php80-iconv
	pkg install --yes php80-zlib php80-filter php80-curl php80-mbstring
	pkg install --yes php80-pdo_pgsql php80-pgsql
fi
if [ ."$php_version" = ."8.1" ]; then
	pkg install --yes php81 php81-phar php81-pdo php81-pdo_odbc php81-pdo_sqlite php81-gd php81-imap
	pkg install --yes php81-ldap php81-sockets php81-simplexml php81-xml php81-session php81-iconv
	pkg install --yes php81-zlib php81-filter php81-curl php81-mbstring
 	pkg install --yes php81-pdo_pgsql php81-pgsql
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
