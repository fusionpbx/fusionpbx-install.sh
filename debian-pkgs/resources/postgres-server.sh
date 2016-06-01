#!/bin/sh

#send a message
echo "Install PostgreSQL"

#Install postgres repo
lsb_release -c |grep -i jessie > /dev/null
if [ $? -eq 0 ]; then
cat > "/etc/apt/sources.list.d/pgsql-pgdg.list" << DELIM
deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main
DELIM
else
cat > "/etc/apt/sources.list.d/pgsql-pgdg.list" << DELIM
deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main
DELIM
fi

#update
apt-get  update 

#generate a random password
password=$(dd if=/dev/urandom bs=1 count=20 2>/dev/null | base64)

#Postgres
echo "Install PostgreSQL and create the database and users\n"
for i in postgresql-server-9.5 php5-pgsql ;do sudo apt-get -y install --force-yes "${i}"; done


#################################################
#Edit the freeswitch systemd toadd pgsql service
#################################################
sed -i /lib/systemd/system/freeswitch.service -e"s#After=syslog.target network.target local-fs.target#After=syslog.target network.target local-fs.target postgresql.service#"

#########################################
#Edit pg_hba.conf to enable sections
########################################
sed -i /etc/postgresql/9.5/main/pg_hba.conf -e 's#\#local#local#'
sed -i /etc/postgresql/9.5/main/pg_hba.conf -e 's#\#host#host#'

#systemd
service postgresql restart

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