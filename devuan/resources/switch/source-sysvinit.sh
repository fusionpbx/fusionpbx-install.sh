#cp "$(dirname $0)/source/freeswitch.service.source" /lib/systemd/system/freeswitch.service
#cp "$(dirname $0)/source/etc.default.freeswitch" /etc/default/freeswitch
#systemctl enable freeswitch
#systemctl unmask freeswitch.service
#systemctl daemon-reload

# re-write for sysvinit
# remember to restart freeswitch at the end

echo "Please configure the sysvinit start up script from the source dir and contribute code here. Thank you."