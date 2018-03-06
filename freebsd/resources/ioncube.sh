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

#copy the php extension .so into the php lib directory
cp ioncube/ioncube_loader_fre_7.1.so /usr/local/lib/php/20160303

#add the 00-ioncube.ini file
echo "zend_extension = /usr/local/lib/php/20160303/ioncube_loader_fre_7.1.so" > /usr/local/etc/php/00-ioncube.ini

#restart the service
service php-fpm restart
