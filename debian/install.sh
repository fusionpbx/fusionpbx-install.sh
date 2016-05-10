#!/bin/sh

#Update Debian
echo "Update Debian"
apt-get upgrade && apt-get update -y --force-yes

#IPTables
resources/./iptables.sh

#FusionPBX
resources/./fusionpbx.sh

#NGINX web server
resources/./nginx.sh

#Fail2ban
resources/./fail2ban.sh

#FreeSWITCH
resources/switch/./package-release.sh
#resources/switch/./package-master.sh
#resources/switch/./source-release.sh

#Postgres
resources/./postgres.sh

#set the ip address
server_address=$(hostname -I)

#restart services
/bin/systemctl daemon-reload
/bin/systemctl restart nginx
/bin/systemctl restart fail2ban
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
