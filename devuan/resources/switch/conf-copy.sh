mv /etc/freeswitch /etc/freeswitch.orig
mkdir /etc/freeswitch
cp -R /var/www/fusionpbx/resources/templates/conf/* /etc/freeswitch
chown -R freeswitch:freeswitch /etc/freeswitch