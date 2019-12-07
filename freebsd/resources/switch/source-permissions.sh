#!/bin/sh

#setup owner and group, permissions and sticky
chown -R www:www /usr/local/freeswitch
chmod -R ug+rw /usr/local/freeswitch
#touch /var/log/freeswitch/freeswitch.log
#chown -R www:www /var/log/freeswitch
find /usr/local/freeswitch -type d -exec chmod 2770 {} \;
