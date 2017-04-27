cp "$(dirname $0)/source/freeswitch.init" /etc/init.d/freeswitch
cp "$(dirname $0)/source/etc.default.freeswitch" /etc/default/freeswitch
update-rc.d freeswitch enable
service freeswitch restart

echo "Please configure the sysvinit start up script from the source dir, test, and contribute code. Thank you."