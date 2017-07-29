cp "$(dirname $0)/source/freeswitch.service.source" /lib/systemd/system/freeswitch.service
cp "$(dirname $0)/source/etc.default.freeswitch.source" /etc/default/freeswitch
if [ -e /proc/user_beancounters ]
then
    echo "Oh, your on OpenVZ! Setting a CPU Scheduler isn't possible :("
    sed -i -e "s/CPUSchedulingPolicy=rr/;CPUSchedulingPolicy=rr/g" /lib/systemd/system/freeswitch.service
fi
systemctl enable freeswitch
systemctl unmask freeswitch.service
systemctl daemon-reload
