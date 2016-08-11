#setup owner and group, permissions and sticky
chown -R www-data:www-data /usr/local/freeswitch
chmod -R ug+rw /usr/local/freeswitch
find /usr/local/freeswitch -type d -exec chmod 2770 {} \;
