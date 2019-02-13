#!/bin/sh

# CentOS 7 install

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./resources/config.sh
. ./resources/colors.sh

# Update CentOS 
verbose "Updating CentOS"
yum -y update && yum -y upgrade

# Add additional repository
yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm

# Installing basics packages
yum -y install ntp yum-utils net-tools epel-release htop vim openssl
 
# Disable SELinux
resources/selinux.sh

#FusionPBX
resources/fusionpbx.sh

#Postgres
resources/postgresql.sh

#NGINX web server
resources/sslcert.sh
resources/nginx.sh

#PHP/PHP-FPM
resources/php.sh

#Firewalld
resources/firewalld.sh

#FreeSWITCH
resources/switch.sh

#Fail2ban
resources/fail2ban.sh

#restart services
verbose "Restarting packages for final configuration"
systemctl daemon-reload
systemctl restart freeswitch
systemctl restart php-fpm
systemctl restart nginx
systemctl restart fail2ban

#add the database schema, user and groups
resources/finish.sh
