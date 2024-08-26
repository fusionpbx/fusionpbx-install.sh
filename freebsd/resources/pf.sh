#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

. ./config.sh
. ./colors.sh
   
#send a message
verbose "Configuring PF"

#enable the service
echo 'pf_enable="YES"' >> /etc/rc.conf
echo 'pf_rules="/etc/pf.conf"' >> /etc/rc.conf
#echo 'pf_flags=""' >> /etc/rc.conf
echo 'pflog_enable="YES"' >> /etc/rc.conf
echo 'pflog_logfile="/var/log/pflog"' >> /etc/rc.conf
#echo 'pflog_flags=""' >> /etc/rc.conf

#copy the pf config file
cp pf/pf.conf /etc/pf.conf

#add the pf table files
touch /etc/pf-pass.conf
touch /etc/pf-block.conf
touch /etc/pf-block-sip-auth-ip.conf
touch /etc/pf-block-sip-auth-fail.conf

