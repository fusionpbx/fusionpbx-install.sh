#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

. ./config.sh
. ./colors.sh
   
#send a message
verbose "Configuring IPFW"

#enable the service
echo 'firewall_enable="YES"' >> /etc/rc.conf
echo 'firewall_script="/etc/ipfw.rules"' >> /etc/rc.conf
echo 'firewall_logging="YES"' >> /etc/rc.conf

echo 'net.inet.ip.fw.one_pass=0' >> /etc/sysctl.conf

#copy the pf config file
cp ipfw/ipfw.rules /etc/ipfw.rules

service ipfw start
