apt-get remove -y freeswitch-systemd
cp "$(dirname $0)/source/freeswitch.service.package" /lib/systemd/system/freeswitch.service
cp "$(dirname $0)/source/etc.default.freeswitch.package" /etc/default/freeswitch
chmod 644 /lib/systemd/system/freeswitch.service 
if [ -e /proc/user_beancounters ]
then
    #Disable CPU Scheduler for OpenVZ, not supported on OpenVZ."
    sed -i -e "s/CPUSchedulingPolicy=rr/;CPUSchedulingPolicy=rr/g" /lib/systemd/system/freeswitch.service
fi
systemctl enable freeswitch
systemctl unmask freeswitch.service
systemctl daemon-reload
systemctl start freeswitch
