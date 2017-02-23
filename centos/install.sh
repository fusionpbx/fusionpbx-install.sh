#!/bin/sh

# CentOS 7 install, no arm arch support

#move to script directory so all relative paths work
cd "$(dirname "$0")"
. ./resources/colors.sh
. ./resources/arguments.sh

if [ $CPU_CHECK = true ] && [ $USE_SWITCH_SOURCE = false ]; then
	#check what the CPU and OS are
	OS_test=$(uname -m)
	CPU_arch='unknown'
	OS_bits='unknown'
	CPU_bits='unknown'
	if [ $OS_test = 'armv7l' ]; then
		OS_bits='32'
		CPU_bits='32'
		# RaspberryPi 3 is actually armv8l but current Raspbian reports the cpu as armv7l and no Raspbian 64Bit has been released at this time
		CPU_arch='arm'
	elif [ $OS_test = 'armv8l' ]; then
		# We currently have no test case for armv8l
		OS_bits='unknown'
		CPU_bits='64'
		CPU_arch='arm'
	elif [ $OS_test = 'i386' ]; then
		OS_bits='32'
	if [ "$(grep -o -w 'lm' /proc/cpuinfo)" = 'lm' ]; then
			CPU_bits='64'
		else
			CPU_bits='32'
		fi
		CPU_arch='x86'
	elif [ $OS_test = 'i686' ]; then
		OS_bits='32'
		if [ "$(grep -o -w 'lm' /proc/cpuinfo)" = 'lm' ]; then
			CPU_bits='64'
		else
			CPU_bits='32'
		fi
		CPU_arch='x86'
	elif [ $OS_test = 'x86_64' ]; then
		OS_bits='64'
		if [ "$(grep -o -w 'lm' /proc/cpuinfo)" = 'lm' ]; then
			CPU_bits='64'
		else
			CPU_bits='32'
		fi
		CPU_arch='x86'
	fi
	
	if [ $CPU_arch = 'arm' ]; then
			error "CentOS on arm is not supported at this time"
			exit 3
	elif [ $CPU_arch = 'x86' ]; then
		if [ $OS_bits = '32' ]; then
			error "You are using a 32bit OS this is unsupported"
			if [ $CPU_bits = '64' ]; then
				warning " Your CPU is 64bit you should consider reinstalling with a 64bit OS"
			fi
			exit 3
		elif [ $OS_bits = '64' ]; then
			verbose "Correct CPU/OS detected"
		else
			error "Unknown OS_bits $OS_bits this is unsupported"
			exit 3
		fi
	else
		error "You are using a unsupported architecture $CPU_arch"
	fi
fi

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
