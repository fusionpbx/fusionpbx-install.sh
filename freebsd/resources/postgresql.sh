#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh

#install the dependencies
pkg install --yes sudo 

#move to /tmp to prevent an error when running sudo with psql
cwd=$(pwd)
cd /tmp

#send a message
echo "Install PostgreSQL"

#generate a random password
password=$(cat /dev/random | env LC_CTYPE=C tr -dc a-zA-Z0-9 | head -c 20)

#install message
echo "Install PostgreSQL and create the database and users\n"

#postgres install
if [ ."$database_version" = ."11" ]; then
	pkg install --yes postgresql11-server
	#cd /usr/ports/databases/postgresql10-server/ && make install clean BATCH=yes
fi
if [ ."$database_version" = ."10" ]; then
	pkg install --yes postgresql10-server
	#cd /usr/ports/databases/postgresql10-server/ && make install clean BATCH=yes
fi
if [ ."$database_version" = ."9.6" ]; then
	pkg install --yes postgresql96-server
	#cd /usr/ports/databases/postgresql96-server/ && make install clean BATCH=yes
fi
if [ ."$database_version" = ."9.5" ]; then
        pkg install --yes postgresql95-server
	#cd /usr/ports/databases/postgresql95-server/ && make install clean BATCH=yes
fi
if [ ."$database_version" = ."9.4" ]; then
        pkg install --yes postgresql94-server
	#cd /usr/ports/databases/postgresql94-server/ && make install clean BATCH=yes
fi
if [ ."$database_version" = ."9.3" ]; then
        pkg install --yes postgresql93-server
	#cd /usr/ports/databases/postgresql93-server/ && make install clean BATCH=yes
fi

#enable postgres
echo 'postgresql_enable=true' >> /etc/rc.conf

#initialize the database
/usr/local/etc/rc.d/postgresql initdb

#start postgresql
if [ ."$database_version" = ."11" ]; then
	sudo -u postgres /usr/local/bin/pg_ctl -D /var/db/postgres/data11 -l logfile start
fi
if [ ."$database_version" = ."10" ]; then
	sudo -u postgres /usr/local/bin/pg_ctl -D /var/db/postgres/data10 -l logfile start
fi
if [ ."$database_version" = ."9.6" ]; then
	sudo -u postgres /usr/local/bin/pg_ctl -D /var/db/postgres/data96 -l logfile start
fi
if [ ."$database_version" = ."9.5" ]; then
	sudo -u postgres /usr/local/bin/pg_ctl -D /var/db/postgres/data95 -l logfile start
fi
if [ ."$database_version" = ."9.4" ]; then
	sudo -u postgres /usr/local/bin/pg_ctl -D /var/db/postgres/data94 -l logfile start
fi
if [ ."$database_version" = ."9.3" ]; then
	sudo -u pgsql /usr/local/bin/pg_ctl -D /usr/local/pgsql/data -l logfile start
fi

#restart the service
service postgresql restart

#install the database backup
#cp backup/fusionpbx-backup.sh /etc/cron.daily
#chmod 755 /etc/cron.daily/fusionpbx-backup.sh
#sed -i' ' -e "s/zzz/$password/g" /etc/cron.daily/fusionpbx-backup.sh

#add the databases, users and grant permissions to them
#sudo -u postgres psql -d fusionpbx -c "DROP SCHEMA public cascade;";
#sudo -u postgres psql -d fusionpbx -c "CREATE SCHEMA public;";
sudo -u postgres psql -c "CREATE DATABASE fusionpbx;";
sudo -u postgres psql -c "CREATE DATABASE freeswitch;";
sudo -u postgres psql -c "CREATE ROLE fusionpbx WITH SUPERUSER LOGIN PASSWORD '$password';"
sudo -u postgres psql -c "CREATE ROLE freeswitch WITH SUPERUSER LOGIN PASSWORD '$password';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE fusionpbx to fusionpbx;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE freeswitch to fusionpbx;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE freeswitch to freeswitch;"
#ALTER USER fusionpbx WITH PASSWORD 'newpassword';

