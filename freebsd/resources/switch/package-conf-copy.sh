#!/bin/sh

#mv /usr/local/etc/freeswitch /usr/local/etc/freeswitch.orig
mkdir -p /usr/local/etc/freeswitch
cp -R /usr/local/www/fusionpbx/resources/templates/conf/* /usr/local/etc/freeswitch
