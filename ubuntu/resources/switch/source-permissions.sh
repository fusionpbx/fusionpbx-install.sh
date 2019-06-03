#setup owner and group, permissions and sticky
chmod -R ug+rw /usr/local/freeswitch
touch /usr/local/freeswitch/freeswitch.log
chown -R www-data:www-data /usr/local/freeswitch
find /usr/local/freeswitch -type d -exec chmod 2770 {} \;
