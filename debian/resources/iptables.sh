#!/bin/sh

#send a message
echo "Configure IPTables"

#run iptables commands

#filter unencrypted traffic to drop known common bots
iptables -N sip_bot_check
iptables -A sip_bot_check -j DROP -m string --string "sipcli/" --algo bm
iptables -A sip_bot_check -j DROP -m string --string "sipvicious" --algo bm
iptables -A sip_bot_check -j DROP -m string --string "sip-scan" --algo bm
iptables -A sip_bot_check -j DROP -m string --string "sipsak" --algo bm
iptables -A sip_bot_check -j DROP -m string --string "sundayddr" --algo bm
iptables -A sip_bot_check -j DROP -m string --string "friendly-scanner" --algo bm
iptables -A sip_bot_check -j DROP -m string --string "iWar" --algo bm
iptables -A sip_bot_check -j DROP -m string --string "SIVuS" --algo bm
iptables -A sip_bot_check -j DROP -m string --string "Gulp" --algo bm
iptables -A sip_bot_check -j DROP -m string --string "sipv" --algo bm
iptables -A sip_bot_check -j DROP -m string --string "smap" --algo bm
iptables -A sip_bot_check -j DROP -m string --string "friendly-request" --algo bm
iptables -A sip_bot_check -j DROP -m string --string "VaxIPUserAgent" --algo bm
iptables -A sip_bot_check -j DROP -m string --string "VaxSIPUserAgent" --algo bm
iptables -A sip_bot_check -j DROP -m string --string "siparmyknife" --algo bm
iptables -A sip_bot_check -j DROP -m string --string "Test Agent" --algo bm
iptables -A sip_bot_check -j ACCEPT

iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp --dport 5060 -j sip_bot_check
iptables -A INPUT -p udp --dport 5060 -j sip_bot_check
iptables -A INPUT -p tcp --dport 5080 -j sip_bot_check
iptables -A INPUT -p udp --dport 5080 -j sip_bot_check
iptables -A INPUT -p tcp --dport 5061 -j ACCEPT
iptables -A INPUT -p udp --dport 5061 -j ACCEPT
iptables -A INPUT -p tcp --dport 5081 -j ACCEPT
iptables -A INPUT -p udp --dport 5081 -j ACCEPT
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
