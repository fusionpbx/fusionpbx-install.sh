#!/bin/sh
# check to confirm running as root. # First, we need to be root...
if [ "$(id -u)" -ne "0" ]; then
  sudo -p "$(basename "$0") must be run as root, please enter your sudo password : " "$0" "$@"
  exit 0
fi
echo
echo "You're root.... continuing!"
echo

# removes the cd img from the /etc/apt/sources.list file (not needed after base install)
sed -i '/cdrom:/d' /etc/apt/sources.list

#if lsb_release is not installed it installs it
if [ ! -s /usr/bin/lsb_release ]; then
	apt-get update && apt-get -y install lsb-release
fi

#Os/Distro Check
lsb_release -c |grep -i jessie > /dev/null
if [ $? -eq 0 ]; then
	echo " OK you are running Debian 8 : Jessie. This script is known to work "
	echo " with building from source. No Jessie pkgs yet. "
else
	echo " This script was written for Debian 8 Jessie (Stable) "
	echo " Your OS appears to be: " lsb_release -a
	echo " Your OS is not currently supported... Exiting the install. "
	exit
fi
clear

#
#Update Debian & install ntpd
for i in update upgrade ;do apt-get -y "${i}" ; done
apt-get -y install ntp
service ntp res

#FreeSWITCH
resources/switch/./package-release.sh
#resources/switch/./package-master.sh
#resources/switch/./source-release.sh

#NGINX web server
resources/./nginx.sh

#FusionPBX
resources/./fusionpbx.sh

#FusionPBX Optional Pkgs
resources/./packages.sh

#FusionPBX Phone Provisioning Selections
resources/./provision.sh

#Fail2ban
resources/./fail2ban.sh

#Postgres-Client
#resources/./postgres-client.sh

#Postgres-server
#resources/./postgres-server.sh

#IPTables
resources/./iptables.sh

#set the ip address
server_address=$(hostname -I)

#restart services
systemctl daemon-reload
systemctl restart nginx
systemctl restart fail2ban
#/usr/sbin/service nginx restart
#/usr/sbin/service fail2ban restart

#Show database password
echo "Complete the install by by going to the IP address of this server ";
echo "in your web browser or with a domain name for this server.";
echo "   https://$server_address"
echo ""
echo ""

#wait for the config.php to exist and then restart the service
#resources/./finish.sh

