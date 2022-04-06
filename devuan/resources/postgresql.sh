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
		apt-get install -q -y sudo postgresql
	else
		apt-get install -q -y sudo postgresql-client
	fi
fi

#postgres official repository
##TODO would newer versions work without systemd?
if [ ."$database_repo" = ."official" ]; then
    verbose "Using official repos"
	echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main' > /etc/apt/sources.list.d/pgdg.list
	wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
	apt-get -q update && apt-get upgrade -y
	apt-get install -y postgresql
fi

#Add PostgreSQL and BDR REPO
##TODO would newer versions work without systemd?
if [ ."$database_repo" = ."2ndquadrant" ]; then
    verbose "Using 2ndquadrant.com repos"
	echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main'  >> /etc/apt/sources.list.d/postgresql.list
	echo 'deb http://packages.2ndquadrant.com/bdr/apt/ jessie-2ndquadrant main' >> /etc/apt/sources.list.d/2ndquadrant.list
	wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -
	wget --quiet -O - http://packages.2ndquadrant.com/bdr/apt/AA7A6805.asc | apt-key add -
	apt-get -q update && apt-get upgrade -y
	apt-get install -y postgresql-bdr-9.4 postgresql-bdr-9.4-bdr-plugin postgresql-bdr-contrib-9.4
fi

#init.d
if [ ."$database_host" = ."127.0.0.1" ] || [ ."$database_host" = ."::1" ] ; then
    /usr/sbin/service postgresql restart
fi

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

if [ ."$database_host" = ."127.0.0.1" ] || [ ."$database_host" = ."::1" ] ; then
	# add the databases, users and grant permissions to them
	sudo -u postgres psql -c "CREATE DATABASE fusionpbx;";
	sudo -u postgres psql -c "CREATE DATABASE freeswitch;";
	sudo -u postgres psql -c "CREATE ROLE fusionpbx WITH SUPERUSER LOGIN PASSWORD '$password';"
	sudo -u postgres psql -c "CREATE ROLE freeswitch WITH SUPERUSER LOGIN PASSWORD '$password';"
	sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE fusionpbx to fusionpbx;"
	sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE freeswitch to fusionpbx;"
	sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE freeswitch to freeswitch;"
	# ALTER USER fusionpbx WITH PASSWORD 'newpassword';
fi

cd $cwd

#set the ip address
#server_address=$(hostname -I)
