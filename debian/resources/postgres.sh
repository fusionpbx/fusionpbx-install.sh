#!/bin/sh

#send a message
echo "Install PostgreSQL"

#generate a random password
password=$(dd if=/dev/urandom bs=1 count=20 2>/dev/null | base64)

#install message
echo "Install PostgreSQL and create the database and users\n"

#included in the distribution
#apt-get install -y --force-yes sudo postgresql

#postgres official repository
postgres_repo_url='deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main'
postgres_repo_file='/etc/apt/sources.list.d/pgdg.list'

#append a line to a file only if it does not already exist
#temp file
random=$(dd if=/dev/urandom bs=1 count=20 2>/dev/null | base64)
postgres_repo_tmp='/tmp/pgdg-'$random'.lst'
rm $postgres_repo_tmp

#append a line
echo ''$postgres_repo_url'' >> $postgres_repo_file

#delete duplicate, nonconsecutive lines from a file
awk '!seen[$0]++' $postgres_repo_file > $postgres_repo_tmp
cat $postgres_repo_tmp > $postgres_repo_file
rm $postgres_repo_tmp

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt-get update && apt-get upgrade -y
apt-get install -y --force-yes sudo postgresql

#Add PostgreSQL and BDR REPO
#echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main'  >> /etc/apt/sources.list.d/postgresql.list
#echo 'deb http://packages.2ndquadrant.com/bdr/apt/ jessie-2ndquadrant main' >> /etc/apt/sources.list.d/2ndquadrant.list
#/usr/bin/wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -
#/usr/bin/wget --quiet -O - http://packages.2ndquadrant.com/bdr/apt/AA7A6805.asc | apt-key add -
#apt-get update && apt-get upgrade -y
#apt-get install -y --force-yes sudo postgresql-bdr-9.4 postgresql-bdr-9.4-bdr-plugin postgresql-bdr-contrib-9.4

#systemd
systemctl daemon-reload
systemctl restart postgresql

#init.d
#/usr/sbin/service postgresql restart

#move to /tmp to prevent a red herring error when running sudo with psql
cwd=$(pwd)
cd /tmp
#add the databases, users and grant permissions to them
sudo -u postgres psql -c "CREATE DATABASE fusionpbx";
sudo -u postgres psql -c "CREATE DATABASE freeswitch";
sudo -u postgres psql -c "CREATE ROLE fusionpbx WITH SUPERUSER LOGIN PASSWORD '$password';"
sudo -u postgres psql -c "CREATE ROLE freeswitch WITH SUPERUSER LOGIN PASSWORD '$password';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE fusionpbx to fusionpbx;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE freeswitch to fusionpbx;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE freeswitch to freeswitch;"
#ALTER USER fusionpbx WITH PASSWORD 'newpassword';
cd $cwd

#set the ip address
#server_address=$(hostname -I)
