cp "$(dirname $0)/source/freeswitch.service" /lib/systemd/system/freeswitch.service
cp "$(dirname $0)/source/etc.default.freeswitch.package" /etc/default/freeswitch
sed -i /lib/systemd/system/freeswitch.service -e s:'-u freeswitch -g freeswitch:-u www-data -g www-data:'
systemctl enable freeswitch
systemctl unmask freeswitch.service
systemctl daemon-reload
