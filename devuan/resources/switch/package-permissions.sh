#default permissions
# Devaun packages set this up correctly
#chown -R freeswitch:freeswitch /var/lib/freeswitch

# I'm not sure this is the best place to put non-packaged files - leaving it as is for now
chown -R freeswitch:freeswitch /usr/share/freeswitch
touch /var/log/freeswitch/freeswitch.log
chown -R freeswitch:freeswitch /var/log/freeswitch