#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh
. ./environment.sh

#get the ioncube 64 bit loader
fetch http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_fre_9_x86-64.tar.gz

#uncompress the file
tar -xvzf ioncube_loaders_fre_9_x86-64.tar.gz

#remove the tar.gz file
rm ioncube_loaders_fre_9_x86-64.tar.gz

#copy the php extension .so into the php lib directory and then add the 00-ioncube.ini file
php_lib_directory=/usr/local/lib/php/20160303
if [ -d "$php_lib_directory/$php_build" ]; then
  cp ioncube/ioncube_loader_fre_7.1.so $php_lib_directory
  echo "zend_extension = $php_lib_directory/ioncube_loader_fre_7.1.so" > /usr/local/etc/php/00-ioncube.ini
fi
php_lib_directory=/usr/local/lib/php/20170718
if [ -d "$php_lib_directory" ]; then
  cp ioncube/ioncube_loader_fre_7.2.so $php_lib_directory
  echo "zend_extension = $php_lib_directory/ioncube_loader_fre_7.2.so" > /usr/local/etc/php/00-ioncube.ini
fi
php_lib_directory=/usr/local/lib/php/20180731
if [ -d "$php_lib_directory" ]; then
  cp ioncube/ioncube_loader_fre_7.3.so $php_lib_directory
  echo "zend_extension = $php_lib_directory/ioncube_loader_fre_7.3.so" > /usr/local/etc/php/00-ioncube.ini
fi
php_lib_directory=/usr/local/lib/php/20190902
if [ -d "$php_lib_directory" ]; then
  cp ioncube/ioncube_loader_fre_7.4.so $php_lib_directory
  echo "zend_extension = $php_lib_directory/ioncube_loader_fre_7.4.so" > /usr/local/etc/php/00-ioncube.ini
fi

#restart the service
service php-fpm restart
