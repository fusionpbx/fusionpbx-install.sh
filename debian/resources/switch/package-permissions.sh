#add users to the groups
usermod -a -G freeswitch www-data
usermod -a -G www-data freeswitch

#setup owner and group, permissions and sticky
chown -R freeswitch:freeswitch /var/lib/freeswitch
chmod -R ug+rw /var/lib/freeswitch
find /var/lib/freeswitch -type d -exec chmod 2770 {} \;

mkdir /usr/share/freeswitch/scripts
chown -R freeswitch:freeswitch /usr/share/freeswitch
chmod -R ug+rw /usr/share/freeswitch
find /usr/share/freeswitch -type d -exec chmod 2770 {} \;

chown -R freeswitch:freeswitch /etc/freeswitch
chmod -R ug+rw /etc/freeswitch
find /etc/freeswitch -type d -exec chmod 2770 {} \;

chown -R freeswitch:freeswitch /var/log/freeswitch
chmod -R ug+rw /var/log/freeswitch
find /var/log/freeswitch -type d -exec chmod 2770 {} \;
