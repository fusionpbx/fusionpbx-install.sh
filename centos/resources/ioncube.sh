#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh
. ./environment.sh

#make sure unzip is install
yum install unzip

#get the ioncube 64 bit loader
wget --no-check-certificate https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.zip

#uncompress the file
unzip ioncube_loaders_lin_x86-64.zip

#remove the zip file
rm ioncube_loaders_lin_x86-64.zip

#copy the php extension .so into the php lib directory
cp ioncube/ioncube_loader_lin_7.1.so /usr/lib64/php/modules

#add the 00-ioncube.ini file
echo "zend_extension = /usr/lib64/php/modules/ioncube_loader_lin_7.1.so" > /etc/php.d/00-ioncube.ini

#restart the service
#service httpd restart
service php-fpm restart
