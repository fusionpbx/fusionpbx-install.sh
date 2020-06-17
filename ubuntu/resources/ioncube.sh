#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh
. ./environment.sh

#make sure unzip is install
apt-get install -y unzip

#remove the ioncube directory if it exists
if [ -d "ioncube" ]; then
        rm -Rf ioncube;
fi

#get the ioncube load and unzip it
if [ .$cpu_architecture = .'x86' ]; then
	#get the ioncube 64 bit loader
	wget --no-check-certificate https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.zip

	#uncompress the file
	unzip ioncube_loaders_lin_x86-64.zip

	#remove the zip file
	rm ioncube_loaders_lin_x86-64.zip
elif [ ."$cpu_architecture" = ."arm" ]; then
	if [ .$cpu_name = .'armv7l' ]; then
		#get the ioncube 64 bit loader
		wget --no-check-certificate https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_armv7l.zip

		#uncompress the file
		unzip ioncube_loaders_lin_armv7l.zip

		#remove the zip file
		rm ioncube_loaders_lin_armv7l.zip
	fi
fi

#copy the loader to the correct directory
if [ ."$php_version" = ."5.6" ]; then
        #copy the php extension .so into the php lib directory
        cp ioncube/ioncube_loader_lin_5.6.so /usr/lib/php5/20131226

        #add the 00-ioncube.ini file
        echo "zend_extension = /usr/lib/php5/20131226/ioncube_loader_lin_5.6.so" > /etc/php5/fpm/conf.d/00-ioncube.ini

        #restart the service
        service php5-fpm restart
fi
if [ ."$php_version" = ."7.0" ]; then
        #copy the php extension .so into the php lib directory
        cp ioncube/ioncube_loader_lin_7.0.so /usr/lib/php/20151012

        #add the 00-ioncube.ini file
        echo "zend_extension = /usr/lib/php/20151012/ioncube_loader_lin_7.0.so" > /etc/php/7.0/fpm/conf.d/00-ioncube.ini

        #restart the service
        service php7.0-fpm restart
fi
if [ ."$php_version" = ."7.1" ]; then
        #copy the php extension .so into the php lib directory
        cp ioncube/ioncube_loader_lin_7.1.so /usr/lib/php/20160303

        #add the 00-ioncube.ini file
        echo "zend_extension = /usr/lib/php/20160303/ioncube_loader_lin_7.1.so" > /etc/php/7.1/fpm/conf.d/00-ioncube.ini

        #restart the service
        service php7.1-fpm restart
fi
if [ ."$php_version" = ."7.2" ]; then
        #copy the php extension .so into the php lib directory
        cp ioncube/ioncube_loader_lin_7.2.so /usr/lib/php/20170718

        #add the 00-ioncube.ini file
        echo "zend_extension = /usr/lib/php/20170718/ioncube_loader_lin_7.2.so" > /etc/php/7.2/fpm/conf.d/00-ioncube.ini
	echo "zend_extension = /usr/lib/php/20170718/ioncube_loader_lin_7.2.so" > /etc/php/7.2/cli/conf.d/00-ioncube.ini

        #restart the service
        service php7.2-fpm restart
fi
