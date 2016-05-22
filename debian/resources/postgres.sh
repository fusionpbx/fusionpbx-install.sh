#!/bin/sh

#send a message
echo "Install PostgreSQL"

#generate a random password
password=$(dd if=/dev/urandom bs=1 count=20 2>/dev/null | base64)

#Postgres
echo "Install PostgreSQL and create the database and users\n"
apt-get install -y --force-yes sudo postgresql

#systemd
/bin/systemctl daemon-reload
/bin/systemctl restart postgresql

#init.d
#/usr/sbin/service postgresql restart

#add the databases, users and grant permissions to them
sudo -u postgres psql -c "CREATE DATABASE fusionpbx";
sudo -u postgres psql -c "CREATE DATABASE freeswitch";
sudo -u postgres psql -c "CREATE ROLE fusionpbx WITH SUPERUSER LOGIN PASSWORD '$password';"
sudo -u postgres psql -c "CREATE ROLE freeswitch WITH SUPERUSER LOGIN PASSWORD '$password';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE fusionpbx to fusionpbx;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE freeswitch to fusionpbx;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE freeswitch to freeswitch;"
#ALTER USER fusionpbx WITH PASSWORD 'newpassword';

#set the ip address
server_address=$(hostname -I)

#Show database password
echo ""
echo ""
echo "PostgreSQL"
echo "   Database name: fusionpbx"
echo "   Database username: fusionpbx"
echo "   Database password: $password"
echo ""
