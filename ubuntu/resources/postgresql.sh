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
	apt-get install -y sudo postgresql
fi

#postgres official repository
if [ ."$database_repo" = ."official" ]; then
	echo "deb http://apt.postgresql.org/pub/repos/apt/ $os_codename-pgdg main" > /etc/apt/sources.list.d/postgresql.list
	wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
	apt-get update && apt-get upgrade -y
	if [ ."$database_version" = ."latest" ]; then
                apt-get install -y sudo postgresql
	fi
	if [ ."$database_version" = ."9.6" ]; then
                apt-get install -y sudo postgresql-$database_version
        fi
	if [ ."$database_version" = ."9.4" ]; then
                apt-get install -y sudo postgresql-$database_version
        fi
fi

#add PostgreSQL and 2ndquadrant repos
if [ ."$database_repo" = ."2ndquadrant" ]; then
	apt install -y curl
	curl https://dl.2ndquadrant.com/default/release/get/deb | bash
	apt-get install -y sudo postgresql-bdr-9.4 postgresql-bdr-9.4-bdr-plugin postgresql-bdr-contrib-9.4
fi

#systemd
systemctl daemon-reload
systemctl restart postgresql

#init.d
#/usr/sbin/service postgresql restart

#install the database backup
#cp backup/fusionpbx-backup /etc/cron.daily
#cp backup/fusionpbx-maintenance /etc/cron.daily
#chmod 755 /etc/cron.daily/fusionpbx-backup
#chmod 755 /etc/cron.daily/fusionpbx-maintenance
#sed -i "s/zzz/$password/g" /etc/cron.daily/fusionpbx-backup
#sed -i "s/zzz/$password/g" /etc/cron.daily/fusionpbx-maintenance

#move to /tmp to prevent a red herring error when running sudo with psql
cwd=$(pwd)
cd /tmp

#add the databases, users and grant permissions to them
sudo -u postgres psql -c "CREATE DATABASE fusionpbx;";
sudo -u postgres psql -c "CREATE DATABASE freeswitch;";
sudo -u postgres psql -c "CREATE ROLE fusionpbx WITH SUPERUSER LOGIN PASSWORD '$password';"
sudo -u postgres psql -c "CREATE ROLE freeswitch WITH SUPERUSER LOGIN PASSWORD '$password';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE fusionpbx to fusionpbx;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE freeswitch to fusionpbx;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE freeswitch to freeswitch;"
#ALTER USER fusionpbx WITH PASSWORD 'newpassword';
cd $cwd

#set the ip address
#server_address=$(hostname -I)
