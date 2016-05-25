#!/bin/sh

#send a message
echo "Configure IPTables"

#run iptables commands
iptables -N sip
iptables -A sip -j DROP -m string --string "friendly-scanner" --algo bm
iptables -A sip -j DROP -m string --string "sipcli/" --algo bm
iptables -A sip -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -j sip -p tcp -m multiport --dports 5060,5061,5080,5081 -m comment --comment "SIP tcp"
iptables -A INPUT -j sip -p udp -m multiport --dports 5060,5061,5080,5081 -m comment --comment "SIP udp"
iptables -A INPUT -j ACCEPT -m state --state ESTABLISHED,RELATED
iptables -A INPUT -j ACCEPT -p tcp --dport 22 -m comment --comment "ssh"
iptables -A INPUT -j ACCEPT -p tcp --dport 80 -m comment --comment "http"
iptables -A INPUT -j ACCEPT -p tcp --dport 443 -m comment --comment "https"
iptables -A INPUT -j ACCEPT -p udp --dport 16384:32768 -m comment --comment "SIP RTP"
iptables -A INPUT -j ACCEPT -p icmp --icmp-type echo-request
iptables -A INPUT -j ACCEPT -p udp --dport 1194 -m comment --comment "OpenVPN"
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

#answer the questions for iptables persistent
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
apt-get install -y --force-yes  iptables-persistent
