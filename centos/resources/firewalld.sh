#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh

#send a message
verbose "Configuring FirewallD"
#ssh should be on by default

#configure the firewall
firewall-cmd --permanent --zone=public --add-service={http,https}
firewall-cmd --permanent --zone=public --add-port={5060,5061,5080,5081}/udp
firewall-cmd --permanent --zone=public --add-port={5060,5061,5080,5081}/tcp
firewall-cmd --permanent --zone=public --add-port=16384-32768/udp

firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p udp --dport 5060:5061 -m string --string "friendly-scanner" --algo bm -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p udp --dport 5060:5061 -m string --string "sipcli/" --algo bm -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p udp --dport 5060:5061 -m string --string "VaxSIPUserAgent/" --algo bm -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p tcp --dport 5060:5061 -m string --string "friendly-scanner" --algo bm -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p tcp --dport 5060:5061 -m string --string "sipcli/" --algo bm -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p tcp --dport 5060:5061 -m string --string "VaxSIPUserAgent/" --algo bm -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p udp --dport 5080:5081 -m string --string "friendly-scanner" --algo bm -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p udp --dport 5080:5081 -m string --string "sipcli/" --algo bm -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p udp --dport 5080:5081 -m string --string "VaxSIPUserAgent/" --algo bm -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p tcp --dport 5080:5081 -m string --string "friendly-scanner" --algo bm -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p tcp --dport 5080:5081 -m string --string "sipcli/" --algo bm -j DROP
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p tcp --dport 5080:5081 -m string --string "VaxSIPUserAgent/" --algo bm -j DROP
firewall-cmd --add-service openvpn
firewall-cmd --permanent --add-service openvpn
firewall-cmd --reload

#send a message
verbose "FirewallD configured"
