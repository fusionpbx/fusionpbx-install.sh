mv /usr/local/freeswitch/conf /usr/local/freeswitch/conf.orig
mkdir -p /etc/freeswitch
mkdir -p /usr/local/freeswitch/conf
cp -R /var/www/fusionpbx/resources/templates/conf/* /usr/local/freeswitch/conf
