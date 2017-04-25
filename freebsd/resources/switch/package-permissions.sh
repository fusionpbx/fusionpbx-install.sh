#!/bin/sh

#includes
. ./config.sh

#default permissions
chown -R www:www /usr/local/etc/freeswitch
chown -R www:www /var/lib/freeswitch
chown -R www:www /usr/local/share/freeswitch
chown -R www:www /var/log/freeswitch
chown -R www:www /var/run/freeswitch
