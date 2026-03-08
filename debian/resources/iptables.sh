#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"


#add the includes
. ./config.sh
. ./colors.sh
. ./environment.sh

#send a message
verbose "Configuring IPTables"

#defaults to nftables by default this enables iptables
if [ ."$os_codename" = ."buster" ]; then
	update-alternatives --set iptables /usr/sbin/iptables-legacy
	update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
fi
if [ ."$os_codename" = ."bullseye" ]; then
	apt-get install -y iptables
	update-alternatives --set iptables /usr/sbin/iptables-legacy
	update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
fi
if [ ."$os_codename" = ."bookworm" ]; then
	apt-get install -y iptables
	update-alternatives --set iptables /usr/sbin/iptables-legacy
	update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
fi

#remove ufw
ufw reset
ufw disable
apt-get remove -y ufw
#apt-get purge ufw
iptables --delete-chain ufw-after-forward
iptables --delete-chain ufw-after-input
iptables --delete-chain ufw-after-logging-forward
iptables --delete-chain ufw-after-logging-input
iptables --delete-chain ufw-after-logging-output
iptables --delete-chain ufw-after-output
iptables --delete-chain ufw-before-forward
iptables --delete-chain ufw-before-input
iptables --delete-chain ufw-before-logging-forward
iptables --delete-chain ufw-before-logging-input
iptables --delete-chain ufw-before-logging-output
iptables --delete-chain ufw-before-output
iptables --delete-chain ufw-reject-forward
iptables --delete-chain ufw-reject-input
iptables --delete-chain ufw-reject-output
iptables --delete-chain ufw-track-forward
iptables --delete-chain ufw-track-input
iptables --delete-chain ufw-track-output

#flush iptables
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -F

#run iptables commands
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -j DROP -p udp --dport 5060:5091 -m string --string "friendly-scanner" --algo bm --icase
iptables -A INPUT -j DROP -p tcp --dport 5060:5091 -m string --string "friendly-scanner" --algo bm --icase
iptables -A INPUT -j DROP -p udp --dport 5060:5091 -m string --string "sipcli/" --algo bm --icase
iptables -A INPUT -j DROP -p tcp --dport 5060:5091 -m string --string "sipcli/" --algo bm --icase
iptables -A INPUT -j DROP -p udp --dport 5060:5091 -m string --string "VaxSIPUserAgent/" --algo bm --icase
iptables -A INPUT -j DROP -p tcp --dport 5060:5091 -m string --string "VaxSIPUserAgent/" --algo bm --icase
iptables -A INPUT -j DROP -p udp --dport 5060:5091 -m string --string "pplsip" --algo bm --icase
iptables -A INPUT -j DROP -p tcp --dport 5060:5091 -m string --string "pplsip" --algo bm --icase
iptables -A INPUT -j DROP -p udp --dport 5060:5091 -m string --string "system " --algo bm --icase
iptables -A INPUT -j DROP -p tcp --dport 5060:5091 -m string --string "system " --algo bm --icase
iptables -A INPUT -j DROP -p udp --dport 5060:5091 -m string --string "exec." --algo bm --icase
iptables -A INPUT -j DROP -p tcp --dport 5060:5091 -m string --string "exec." --algo bm --icase
iptables -A INPUT -j DROP -p udp --dport 5060:5091 -m string --string "multipart/mixed;boundary" --algo bm --icase
iptables -A INPUT -j DROP -p tcp --dport 5060:5091 -m string --string "multipart/mixed;boundary" --algo bm --icase
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp --dport 7443 -j ACCEPT
iptables -A INPUT -p tcp --dport 5060:5091 -j ACCEPT
iptables -A INPUT -p udp --dport 5060:5091 -j ACCEPT
iptables -A INPUT -p udp --dport 16384:32768 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -p udp --dport 1194 -j ACCEPT
iptables -t mangle -A OUTPUT -p udp -m udp --sport 16384:32768 -j DSCP --set-dscp 46
iptables -t mangle -A OUTPUT -p udp -m udp --sport 5060:5091 -j DSCP --set-dscp 26
iptables -t mangle -A OUTPUT -p tcp -m tcp --sport 5060:5091 -j DSCP --set-dscp 26
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

#save iptables to make it persistent
#mkdir /etc/iptables
#iptables-save > /etc/iptables/rules.v4

#answer the questions for iptables persistent and save the iptable rules
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
apt-get install -y iptables-persistent
