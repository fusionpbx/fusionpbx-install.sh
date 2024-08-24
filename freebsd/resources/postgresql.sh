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
if [ ."$database_version" = ."16" ]; then
	echo "IGNORE_DEPENDS=postgresql15-client" >> /usr/local/etc/pkg.conf
	pkg install --yes postgresql16-server
	#cd /usr/ports/databases/postgresql16-server/ && make install clean BATCH=yes
fi
if [ ."$database_version" = ."15" ]; then
	pkg install --yes postgresql15-server
	#cd /usr/ports/databases/postgresql15-server/ && make install clean BATCH=yes
fi
if [ ."$database_version" = ."14" ]; then
	pkg install --yes postgresql14-server
	#cd /usr/ports/databases/postgresql14-server/ && make install clean BATCH=yes
fi
if [ ."$database_version" = ."13" ]; then
	pkg install --yes postgresql13-server
	#cd /usr/ports/databases/postgresql13-server/ && make install clean BATCH=yes
fi
if [ ."$database_version" = ."12" ]; then
	pkg install --yes postgresql12-server
	#cd /usr/ports/databases/postgresql12-server/ && make install clean BATCH=yes
fi

#enable postgres
echo 'postgresql_enable=true' >> /etc/rc.conf

#initialize the database
/usr/local/etc/rc.d/postgresql initdb

#start postgresql
if [ ."$database_version" = ."16" ]; then
	sudo -u postgres /usr/local/bin/pg_ctl -D /var/db/postgres/data16 start
fi
if [ ."$database_version" = ."15" ]; then
	sudo -u postgres /usr/local/bin/pg_ctl -D /var/db/postgres/data15 start
fi
if [ ."$database_version" = ."14" ]; then
	sudo -u postgres /usr/local/bin/pg_ctl -D /var/db/postgres/data14 start
fi
if [ ."$database_version" = ."13" ]; then
	sudo -u postgres /usr/local/bin/pg_ctl -D /var/db/postgres/data13 start
fi
if [ ."$database_version" = ."12" ]; then
	sudo -u postgres /usr/local/bin/pg_ctl -D /var/db/postgres/data12 start
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

