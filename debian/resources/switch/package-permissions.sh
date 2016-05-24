#add users to the groups
usermod -a -G freeswitch www-data
usermod -a -G www-data freeswitch

#setup owner and group, permissions and sticky
chown -R freeswitch:freeswitch /var/lib/freeswitch
chmod -R 760 /var/lib/freeswitch
chmod -R g+s /var/lib/freeswitch

chown -R freeswitch:freeswitch /usr/share/freeswitch
chmod -R 760 /usr/share/freeswitch
chmod -R 760 /usr/share/freeswitch/scripts
chmod -R 760 /usr/share/freeswitch/lang
chmod -R g+s /usr/share/freeswitch

chown -R freeswitch:freeswitch /etc/freeswitch
chmod -R 760 /etc/freeswitch
chmod -R g+s /etc/freeswitch

chown -R freeswitch:freeswitch /var/log/freeswitch
chmod -R 760 /var/log/freeswitch
chmod -R g+s /var/log/freeswitch
