#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

. ./colors.sh
. ./arguments.sh

#send a message
verbose "Configuring IPTables"

#run iptables commands
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -j DROP -p udp --dport 5060:5061 -m string --string "friendly-scanner" --algo bm
iptables -A INPUT -j DROP -p udp --dport 5060:5061 -m string --string "sipcli/" --algo bm
iptables -A INPUT -j DROP -p udp --dport 5060:5061 -m string --string "VaxSIPUserAgent/" --algo bm
iptables -A INPUT -j DROP -p tcp --dport 5060:5061 -m string --string "friendly-scanner" --algo bm
iptables -A INPUT -j DROP -p tcp --dport 5060:5061 -m string --string "sipcli/" --algo bm
iptables -A INPUT -j DROP -p tcp --dport 5060:5061 -m string --string "VaxSIPUserAgent/" --algo bm
iptables -A INPUT -j DROP -p udp --dport 5080:5081 -m string --string "friendly-scanner" --algo bm
iptables -A INPUT -j DROP -p udp --dport 5080:5081 -m string --string "sipcli/" --algo bm
iptables -A INPUT -j DROP -p udp --dport 5080:5081 -m string --string "VaxSIPUserAgent/" --algo bm
iptables -A INPUT -j DROP -p tcp --dport 5080:5081 -m string --string "friendly-scanner" --algo bm
iptables -A INPUT -j DROP -p tcp --dport 5080:5081 -m string --string "sipcli/" --algo bm
iptables -A INPUT -j DROP -p tcp --dport 5080:5081 -m string --string "VaxSIPUserAgent/" --algo bm
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp --dport 5060:5061 -j ACCEPT
iptables -A INPUT -p udp --dport 5060:5061 -j ACCEPT
iptables -A INPUT -p tcp --dport 5080:5081 -j ACCEPT
iptables -A INPUT -p udp --dport 5080:5081 -j ACCEPT
iptables -A INPUT -p udp --dport 16384:32768 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -p udp --dport 1194 -j ACCEPT
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

#answer the questions for iptables persistent
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
apt-get install -y iptables-persistent
