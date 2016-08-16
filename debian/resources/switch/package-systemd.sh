apt-get remove -y --force-yes freeswitch-systemd
cp "$(dirname $0)/source/freeswitch.service.package" /lib/systemd/system/freeswitch.service
cp "$(dirname $0)/source/etc.default.freeswitch" /etc/default/freeswitch
systemctl enable freeswitch
systemctl unmask freeswitch.service
systemctl daemon-reload
systemctl start freeswitch
