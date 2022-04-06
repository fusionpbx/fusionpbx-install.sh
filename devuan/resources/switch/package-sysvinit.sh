cp "$(dirname $0)/freeswitch.init" /etc/init.d/freeswitch
cp "$(dirname $0)/etc.default.freeswitch" /etc/default/freeswitch

/usr/sbin/update-rc.d freeswitch enable
/usr/sbin/service freeswitch restart
