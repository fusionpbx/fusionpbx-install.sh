#!/bin/sh

#send a message
echo "Configure IPTables"

#run iptables commands
iptables -A INPUT -j DROP -p udp --dport 5060 -m string --string "friendly-scanner" --algo bm
iptables -A INPUT -j DROP -p udp --dport 5060 -m string --string "sipcli/" --algo bm
iptables -A INPUT -j DROP -p tcp --dport 5060 -m string --string "friendly-scanner" --algo bm
iptables -A INPUT -j DROP -p tcp --dport 5060 -m string --string "sipcli/" --algo bm
iptables -A INPUT -j DROP -p udp --dport 5080 -m string --string "friendly-scanner" --algo bm
iptables -A INPUT -j DROP -p udp --dport 5080 -m string --string "sipcli/" --algo bm
iptables -A INPUT -j DROP -p tcp --dport 5080 -m string --string "friendly-scanner" --algo bm
iptables -A INPUT -j DROP -p tcp --dport 5080 -m string --string "sipcli/" --algo bm
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp --dport 5060 -j ACCEPT
iptables -A INPUT -p udp --dport 5060 -j ACCEPT
iptables -A INPUT -p tcp --dport 5080 -j ACCEPT
iptables -A INPUT -p udp --dport 5080 -j ACCEPT
iptables -A INPUT -p udp --dport 16384:32768 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -p udp --dport 1194 -j ACCEPT
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

#answer the questions for iptables persistent
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
apt-get install -y --force-yes  iptables-persistent
