#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ../config.sh

#set the date
now=$(date +%Y-%m-%d)

#show this server's addresses
server_address=$(hostname -I);
echo "This Server Address: $server_address"

#nodes addresses
read -p "Enter all Node IP Addresses: " nodes

#determine whether to add iptable rules
read -p 'Add iptable rules (y/n): ' iptables_add

#settings summary
echo "-----------------------------";
echo " Summary";
echo "-----------------------------";
echo "All Node IP Addresses: $nodes";
echo "Add iptable rules: $iptables_add";
echo "";

#verify
read -p 'Is the information correct (y/n): ' verified 
if [ .$verified != ."y" ]; then
	echo "Goodbye";
	exit 0;
fi

#iptables rules
if [ .$iptables_add = ."y" ]; then
	for node in $nodes; do
		/usr/sbin/iptables -A INPUT -j ACCEPT -p tcp --dport 5432 -s ${node}/32
		/usr/sbin/iptables -A INPUT -j ACCEPT -p tcp --dport 22000 -s ${node}/32
	done
	apt-get remove iptables-persistent -y
	echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
	echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
	apt-get install -y iptables-persistent
fi

#set the working directory
cwd=$(pwd)
cd /tmp

#message to user
echo "Completed"
