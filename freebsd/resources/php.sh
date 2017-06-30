#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

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
	pkg install --yes php56-imap php56-ldap php56-mcrypt php56-openssl php56-sockets php56-simplexml php56-xml php56-session
fi
if [ ."$php_version" = ."7" ]; then
	#pkg install --yes php70 php70-phar php70-pgsql php70-pdo php70-pdo_pgsql php70-pdo_odbc php70-pdo_sqlite php70-json php70-gd 
	#pkg install --yes php70-imap php70-ldap php70-mcrypt php70-openssl php70-sockets php70-simplexml php70-xml php70-session
	pkg install --yes php71 php71-phar php71-pdo php71-pdo_odbc php71-pdo_sqlite php71-json php71-gd php71-imap
	pkg install --yes php71-ldap php71-mcrypt php71-openssl php71-sockets php71-simplexml php71-xml php71-session
	if [ ."$database_version" = ."9.3" ]; then
		pkg install --yes postgresql93-client
		pkg install --yes php71-pdo_pgsql php71-pgsql
	fi
	if [ ."$database_version" = ."9.6" ]; then
		pkg install --yes postgresql96-client
		if [ .$(freebsd-version -k | head -c 2) = ."10" ]; then
			pkg add https://www.fusionpbx.com/downloads/freebsd10/php71-pdo_pgsql-7.1.6_1.txz
			pkg add https://www.fusionpbx.com/downloads/freebsd10/php71-pgsql-7.1.6_1.txz
		fi
		if [ .$(freebsd-version -k | head -c 2) = ."11" ]; then
			pkg add https://www.fusionpbx.com/downloads/freebsd11/php71-pdo_pgsql-7.1.6_1.txz
			pkg add https://www.fusionpbx.com/downloads/freebsd11/php71-pgsql-7.1.6_1.txz
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

#send a message
verbose "Configuring PHP"

#update config if source is being used
cp /usr/local/etc/php.ini-production /usr/local/etc/php.ini
sed -i' ' -e s:'post_max_size = .*:post_max_size = 80M:g' /usr/local/etc/php.ini
sed -i' ' -e s:'upload_max_filesize = .*:upload_max_filesize = 80M:g' /usr/local/etc/php.ini

#restart php-fpm
service php-fpm restart
