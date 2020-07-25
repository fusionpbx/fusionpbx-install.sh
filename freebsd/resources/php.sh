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
if [ ."$php_version" = ."5" ]; then
	pkg install --yes php56 php56-phar php56-pgsql php56-pdo php56-pdo_pgsql php56-pdo_odbc php56-pdo_sqlite php56-json php56-gd
	pkg install --yes php56-imap php56-ldap php56-openssl php56-sockets php56-simplexml php56-xml php56-session php56-filter
fi
if [ ."$php_version" = ."7.1" ]; then
	#pkg install --yes php70 php70-phar php70-pgsql php70-pdo php70-pdo_pgsql php70-pdo_odbc php70-pdo_sqlite php70-json php70-gd 
	#pkg install --yes php70-imap php70-ldap php70-openssl php70-sockets php70-simplexml php70-xml php70-session
	pkg install --yes php71 php71-phar php71-pdo php71-pdo_odbc php71-pdo_sqlite php71-json php71-gd php71-imap
	pkg install --yes php71-ldap php71-openssl php71-sockets php71-simplexml php71-xml php71-session php71-filter
	if [ ."$database_version" = ."9.3" ]; then
		pkg install --yes postgresql93-client
		pkg install --yes php71-pdo_pgsql php71-pgsql
	fi
	if [ ."$database_version" = ."9.6" ]; then
		pkg install --yes postgresql96-client
		if [ .$(freebsd-version | head -c 2) = ."10" ]; then
			pkg add https://www.fusionpbx.com/downloads/freebsd/10/php71-pdo_pgsql-7.1.6_1.txz
			pkg add https://www.fusionpbx.com/downloads/freebsd/10/php71-pgsql-7.1.6_1.txz
		fi
		if [ .$(freebsd-version | head -c 2) = ."11" ]; then
			pkg add https://www.fusionpbx.com/downloads/freebsd/11/php71-pdo_pgsql-7.1.6_1.txz
			pkg add https://www.fusionpbx.com/downloads/freebsd/11/php71-pgsql-7.1.6_1.txz
		fi

		##set the current working directory
		#cwd=$(pwd)
		#install the packages from the ports
		#cd /usr/ports/databases/php71-pdo_pgsql/ && make install clean BATCH=yes
		#cd /usr/ports/databases/php71-pgsql && make install clean BATCH=yes
		##reset the current working directory
		#cd $cwd
	fi
fi
if [ ."$php_version" = ."7.2" ]; then
	pkg install --yes php72 php72-phar php72-pdo php72-pdo_odbc php72-pdo_sqlite php72-json php72-gd php72-imap
	pkg install --yes php72-ldap php72-openssl php72-sockets php72-simplexml php72-xml php72-session php72-iconv
	pkg intsall --yes php72-zlib php72-filter
	if [ ."$database_version" = ."9.5" ]; then
		pkg install --yes postgresql95-client
		pkg install --yes php72-pdo_pgsql php72-pgsql
	fi
	if [ ."$database_version" = ."10" ]; then
		pkg install --yes postgresql10-client
		if [ .$(freebsd-version | head -c 2) = ."11" ]; then
			pkg add -f https://www.fusionpbx.com/downloads/freebsd/11/php72-pgsql10-7.2.5.txz
			pkg add -f https://www.fusionpbx.com/downloads/freebsd/11/php72-pdo_pgsql10-7.2.5.txz
		fi
		if [ .$(freebsd-version | head -c 2) = ."12" ]; then
			pkg add -f https://www.fusionpbx.com/downloads/freebsd/12/php72-pgsql-7.2.15.txz
			pkg add -f https://www.fusionpbx.com/downloads/freebsd/12/php72-pdo_pgsql-7.2.15.txz	
		fi
	fi
fi
if [ ."$php_version" = ."7.3" ]; then
	pkg install --yes php73 php73-phar php73-pdo php73-pdo_odbc php73-pdo_sqlite php73-json php73-gd php73-imap
	pkg install --yes php73-ldap php73-openssl php73-sockets php73-simplexml php73-xml php73-session php73-iconv
	pkg intsall --yes php73-zlib php73-filter
	if [ ."$database_version" = ."11" ]; then
		pkg install --yes postgresql11-client
		pkg install --yes php73-pdo_pgsql php73-pgsql
	fi
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
