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

#use the system database repo for arm
if [ .$cpu_architecture = .'arm' ]; then
        database_repo="system"
fi

#included in the distribution
if [ ."$database_repo" = ."system" ]; then
	apt-get install -y --force-yes sudo postgresql
fi

#postgres official repository
if [ ."$database_repo" = ."official" ]; then
	echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main' > /etc/apt/sources.list.d/pgdg.list
	wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
	apt-get update && apt-get upgrade -y
	apt-get install -y --force-yes sudo postgresql
fi

#Add PostgreSQL and BDR REPO
if [ ."$database_repo" = ."2ndquadrant" ]; then
	echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main'  >> /etc/apt/sources.list.d/postgresql.list
	echo 'deb http://packages.2ndquadrant.com/bdr/apt/ jessie-2ndquadrant main' >> /etc/apt/sources.list.d/2ndquadrant.list
	/usr/bin/wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -
	/usr/bin/wget --quiet -O - http://packages.2ndquadrant.com/bdr/apt/AA7A6805.asc | apt-key add -
	apt-get update && apt-get upgrade -y
	apt-get install -y --force-yes sudo postgresql-bdr-9.4 postgresql-bdr-9.4-bdr-plugin postgresql-bdr-contrib-9.4
fi

#systemd
systemctl daemon-reload
systemctl restart postgresql

#init.d
#/usr/sbin/service postgresql restart

#enable and run the backup
cp backup/fusionpbx-backup.sh /etc/cron.daily
chmod 755 /etc/cron.daily/fusionpbx-backup.sh
sed -i "s/zzz/$password/g" /etc/cron.daily/fusionpbx-backup.sh
/etc/cron.daily/fusionpbx-backup.sh

#move to /tmp to prevent a red herring error when running sudo with psql
cwd=$(pwd)
cd /tmp
#add the databases, users and grant permissions to them
sudo -u postgres psql -c "DROP SCHEMA public cascade;";
sudo -u postgres psql -c "CREATE SCHEMA public;";
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
