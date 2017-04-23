#!/bin/sh

# CentOS 7 install, no arm arch support

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./resources/config.sh
. ./resources/colors.sh



# Update CentOS 
verbose "Updating CentOS"
yum -y update && yum -y upgrade

# Installing basics packages
yum -y install ntp htop epel-release vim openssl

# Disable SELinux
verbose "Disabling SELinux"
warning "Reboot required after installation completes"
setenforce 0
sed -i 's/\(^SELINUX=\).*/\SELINUX=disabled/' /etc/selinux/config
verbose "SELinux disabled"

#FreeSWITCH
resources/switch/package-release.sh

#FusionPBX
resources/fusionpbx.sh

#Postgres
resources/postgres.sh

#NGINX web server
resources/sslcert.sh
resources/nginx.sh

#PHP/PHP-FPM
resources/php.sh

#IPTables
resources/firewalld.sh

# FusionPBX to FreeSWITCH configs
verbose "Configuring freeswitch"
resources/switch/conf-copy.sh
resources/switch/package-permissions.sh
resources/switch/package-systemd.sh
verbose "freeswitch configured"

#Fail2ban
resources/fail2ban.sh

#restart services
verbose "Restarting packages for final configuration"
systemctl daemon-reload
systemctl restart freeswitch
systemctl restart php-fpm
systemctl restart nginx
systemctl restart fail2ban
verbose "Restart of service complete"

#add the database schema, user and groups
resources/finish.sh
