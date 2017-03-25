#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh

#send a message
echo "Install PostgreSQL"

#generate a random password
password=$(cat /dev/random | env LC_CTYPE=C tr -dc a-zA-Z0-9 | head -c 16)

#install message
echo "Install PostgreSQL and create the database and users\n"

#postgres install
if [ ."$database_version" = ."9.6" ]; then
	pkg install --yes postgresql96-server
fi
if [ ."$database_version" = ."9.5" ]; then
        pkg install --yes postgresql95-server
fi
if [ ."$database_version" = ."9.4" ]; then
        pkg install --yes postgresql94-server
fi
if [ ."$database_version" = ."9.3" ]; then
        pkg install --yes postgresql93-server
fi

#enable postgres
echo 'postgresql_enable=true' >> /etc/rc.conf

#initialize the database
/usr/local/etc/rc.d/postgresql initdb

#restart the service
service postgresql restart

#install the database backup
#cp backup/fusionpbx-backup.sh /etc/cron.daily
#chmod 755 /etc/cron.daily/fusionpbx-backup.sh
#sed -i "s/zzz/$password/g" /etc/cron.daily/fusionpbx-backup.sh

#move to /tmp to prevent an error when running sudo with psql
cwd=$(pwd)
cd /tmp

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

