#add users to the groups
usermod -a -G freeswitch www-data
usermod -a -G www-data freeswitch

#setup owner and group, permissions and sticky
chown -R freeswitch:freeswitch /usr/local/freeswitch
chmod -R ug+rw /usr/local/freeswitch
find /usr/local/freeswitch -type d -exec chmod 2770 {} \;
