#!/bin/sh

#remove php5
apt remove -y php5 php5-cli php5-fpm php5-pgsql php5-sqlite php5-odbc php5-curl php5-imap php5-gd

#remove php 7.0
apt remove -y php7.0 php7.0-cli php7.0-fpm php7.0-pgsql php7.0-sqlite3 php7.0-odbc php7.0-curl php7.0-imap php7.0-xml php7.0-gd

#remove php 7.1
apt remove -y php7.1 php7.1-cli php7.1-fpm php7.1-pgsql php7.1-sqlite3 php7.1-odbc php7.1-curl php7.1-imap php7.1-xml php7.1-gd

#remove php 7.2
apt remove -y php7.2 php7.2-cli php7.2-fpm php7.2-pgsql php7.2-sqlite3 php7.2-odbc php7.2-curl php7.2-imap php7.2-xml php7.2-gd

#remove php 7.4
apt remove -y php7.4 php7.4-cli php7.4-fpm php7.4-pgsql php7.4-sqlite3 php7.4-odbc php7.4-curl php7.4-imap php7.4-xml php7.4-gd

#remove php 8.1
apt remove -y php8.1 php8.1-cli php8.1-fpm php8.1-pgsql php8.1-sqlite3 php8.1-odbc php8.1-curl php8.1-imap php8.1-xml php8.1-gd php8.1-mbstring php8.1-ldap

#remove php 8.2
apt remove -y php8.2 php8.2-cli php8.2-fpm php8.2-pgsql php8.2-sqlite3 php8.2-odbc php8.2-curl php8.2-imap php8.2-xml php8.2-gd php8.2-mbstring php8.2-ldap

#add ppa repo
which add-apt-repository || apt-get install -y software-properties-common
LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
apt-get update

#install php 7.4
if [ ."$php_version" = ."7.4" ]; then
	#install php 7.4
	/usr/bin/apt-get install -y php7.4 php7.4-cli php7.4-dev php7.4-fpm php7.4-pgsql php7.4-sqlite3 php7.4-odbc php7.4-curl php7.4-imap php7.4-xml php7.4-gd php7.4-mbstring php7.4-ldap
 
	#update the unix socket name
	/usr/bin/sed -i /etc/nginx/sites-available/fusionpbx -e 's#unix:.*;#unix:/var/run/php/php7.4-fpm.sock;#g'

	#set the PHP ini file path
	php_ini_file='/etc/php/7.4/fpm/php.ini'
fi

#install php 8.1
if [ ."$php_version" = ."8.1" ]; then
	#install php 8.1
	/usr/bin/apt-get install -y php8.1 php8.1-cli php8.1-dev php8.1-fpm php8.1-pgsql php8.1-sqlite3 php8.1-odbc php8.1-curl php8.1-imap php8.1-xml php8.1-gd php8.1-mbstring php8.1-ldap
 
  	#update the unix socket name
	/usr/bin/sed -i /etc/nginx/sites-available/fusionpbx -e 's#unix:.*;#unix:/var/run/php/php8.1-fpm.sock;#g'

	#set the PHP ini file path
	php_ini_file='/etc/php/8.1/fpm/php.ini'
fi

#update config if source is being used
sed 's#post_max_size = .*#post_max_size = 80M#g' -i $php_ini_file
sed 's#upload_max_filesize = .*#upload_max_filesize = 80M#g' -i $php_ini_file
sed 's#;max_input_vars = .*#max_input_vars = 8000#g' -i $php_ini_file
sed 's#; max_input_vars = .*#max_input_vars = 8000#g' -i $php_ini_file

#restart nginx
service nginx restart
