#setup owner and group, permissions and sticky
chown -R www-data:www-data /usr/local/freeswitch
chmod -R ug+rw /usr/local/freeswitch
touch /var/log/freeswitch/freeswitch.log
chown -R www-data:www-data /var/log/freeswitch
find /usr/local/freeswitch -type d -exec chmod 2770 {} \;
