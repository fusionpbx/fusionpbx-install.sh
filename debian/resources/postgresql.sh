#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh
. ./environment.sh

#send a message
echo "Install PostgreSQL"

#generate a random password
password=$(dd if=/dev/urandom bs=1 count=20 2>/dev/null | base64)

#install message
echo "Install PostgreSQL and create the database and users\n"

#included in the distribution
if [ ."$database_repo" = ."system" ]; then
	if [ ."$database_host" = ."127.0.0.1" ] || [ ."$database_host" = ."::1" ] ; then
		apt-get install -y sudo postgresql
	else
		apt-get install -y sudo postgresql-client
	fi
fi

#make sure keyrings directory exits
mkdir /etc/apt/keyrings

#postgres official repository
if [ ."$database_repo" = ."official" ]; then
	apt install -y gpg
	sh -c 'echo "deb [signed-by=/etc/apt/keyrings/pgdg.gpg] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
	wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/keyrings/pgdg.gpg
	chmod 644 /etc/apt/keyrings/pgdg.gpg
	apt-get update && apt-get upgrade -y
	if [ ."$database_host" = ."127.0.0.1" ] || [ ."$database_host" = ."::1" ] ; then
		if [ ."$database_version" = ."latest" ]; then
			apt-get install -y sudo postgresql
                else
                        apt-get install -y sudo postgresql-$database_version
                fi
	else
		apt-get install -y sudo postgresql-client
	fi
fi

#add PostgreSQL and 2ndquadrant repos
if [ ."$database_repo" = ."2ndquadrant" ]; then
	if [ ."$database_host" = ."127.0.0.1" ] || [ ."$database_host" = ."::1" ] ; then
		apt install -y curl
		curl https://dl.2ndquadrant.com/default/release/get/deb | bash
		if [ ."$os_codename" = ."buster" ]; then
			sed -i /etc/apt/sources.list.d/2ndquadrant-dl-default-release.list -e 's#buster#stretch#g'
		fi
		if [ ."$os_codename" = ."bullseye" ]; then
			sed -i /etc/apt/sources.list.d/2ndquadrant-dl-default-release.list -e 's#bullseye#stretch#g'
		fi
		apt update
		apt-get install -y sudo postgresql-bdr-9.4 postgresql-bdr-9.4-bdr-plugin postgresql-bdr-contrib-9.4	
	fi
fi

#install the database backup
#cp backup/fusionpbx-backup /etc/cron.daily
#cp backup/fusionpbx-maintenance /etc/cron.daily
#chmod 755 /etc/cron.daily/fusionpbx-backup
#chmod 755 /etc/cron.daily/fusionpbx-maintenance
#sed -i "s/zzz/$password/g" /etc/cron.daily/fusionpbx-backup
#sed -i "s/zzz/$password/g" /etc/cron.daily/fusionpbx-maintenance

#initialize the database
pg_createcluster $database_version main

#replace scram-sha-256 with md5
sed -i /etc/postgresql/$database_version/main/pg_hba.conf -e '/^#/!s/scram-sha-256/md5/g'

#systemd
if [ ."$database_host" = ."127.0.0.1" ] || [ ."$database_host" = ."::1" ] ; then
	systemctl daemon-reload
	systemctl restart postgresql
fi

#init.d
#/usr/sbin/service postgresql restart

#move to /tmp to prevent a red herring error when running sudo with psql
cwd=$(pwd)
cd /tmp

if [ ."$database_host" = ."127.0.0.1" ] || [ ."$database_host" = ."::1" ] ; then
	#reload the config
  	sudo -u postgres psql -c "SELECT pg_reload_conf();"

	#set client encoding
	sudo -u postgres psql -c "SET client_encoding = 'UTF8';";

	#add the database users and databases
	sudo -u postgres psql -c "CREATE DATABASE fusionpbx;";

 	#add the users and grant permissions
	sudo -u postgres psql -c "CREATE ROLE fusionpbx WITH SUPERUSER LOGIN PASSWORD '$password';"
	sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE fusionpbx to fusionpbx;"

 	#update the fusionpbx user password
	#ALTER USER fusionpbx WITH PASSWORD 'newpassword';
fi

cd $cwd

#set the ip address
#server_address=$(hostname -I)
