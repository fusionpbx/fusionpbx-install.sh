apt-get remove -y freeswitch-systemd
cp "$(dirname $0)/source/freeswitch.service.package" /lib/systemd/system/freeswitch.service
cp "$(dirname $0)/source/etc.default.freeswitch.package" /etc/default/freeswitch
chmod 644 /lib/systemd/system/freeswitch.service
if [ -e /proc/user_beancounters ] || systemd-detect-virt --container --quiet 2>/dev/null
then
    #Disable the realtime scheduling, it is not allowed in OpenVZ and in unprivileged containers (LXC).
    #FreeSWITCH would fail to start with "Failed to set up CPU scheduling: Operation not permitted".
    sed -i -e "s/^IOSchedulingClass=/;IOSchedulingClass=/" \
           -e "s/^IOSchedulingPriority=/;IOSchedulingPriority=/" \
           -e "s/^CPUSchedulingPolicy=/;CPUSchedulingPolicy=/" \
           -e "s/^CPUSchedulingPriority=/;CPUSchedulingPriority=/" /lib/systemd/system/freeswitch.service
fi
systemctl enable freeswitch
systemctl unmask freeswitch.service
systemctl daemon-reload
systemctl start freeswitch

#wait until FreeSWITCH answers on the event socket, the next steps read the switch settings from it
if command -v fs_cli >/dev/null 2>&1; then
    i=0
    while [ $i -lt 30 ]; do
        if fs_cli -x "status" >/dev/null 2>&1; then
            break
        fi
        i=$((i+1))
        sleep 2
    done
    if [ $i -ge 30 ]; then
        echo "WARNING: FreeSWITCH did not answer on the event socket after 60 seconds."
        echo "Check: systemctl status freeswitch"
    fi
fi
