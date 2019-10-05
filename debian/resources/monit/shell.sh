#!/bin/sh

mkdir -p /var/run/freeswitch
chown -R www-data:www-data /var/run/freeswitch
/usr/bin/freeswitch -nc -u www-data -g www-data -nonat
