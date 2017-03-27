rm -f /lib/systemd/system/freeswitch.service
cp "$(dirname $0)/source/freeswitch.service.package" /lib/systemd/system/freeswitch.service
cp "$(dirname $0)/source/etc.default.freeswitch" /etc/sysconfig/freeswitch