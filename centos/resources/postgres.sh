#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

. ./colors.sh
. ./arguments.sh

#send a message
verbose "Installing PostgreSQL 9.4"

#generate a random password
password=$(dd if=/dev/urandom bs=1 count=20 2>/dev/null | base64)

#included in the distribution
rpm -ivh --quiet http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/pgdg-centos94-9.4-3.noarch.rpm
yum -y update
yum -y install postgresql94-server postgresql94-contrib postgresql94

verbose "Initalize PostgreSQL database"
/usr/pgsql-9.4/bin/postgresql94-setup initdb

sed -i 's/\(host  *all  *all  *127.0.0.1\/32  *\)ident/\1md5/' /var/lib/pgsql/9.4/data/pg_hba.conf
sed -i 's/\(host  *all  *all  *::1\/128  *\)ident/\1md5/' /var/lib/pgsql/9.4/data/pg_hba.conf

#systemd
systemctl daemon-reload
systemctl restart postgresql-9.4

#move to /tmp to prevent a red herring error when running sudo with psql
cwd=$(pwd)
cd /tmp
#add the databases, users and grant permissions to them
sudo -u postgres /usr/pgsql-9.4/bin/psql -c "CREATE DATABASE fusionpbx";
sudo -u postgres /usr/pgsql-9.4/bin/psql -c "CREATE DATABASE freeswitch";
sudo -u postgres /usr/pgsql-9.4/bin/psql -c "CREATE ROLE fusionpbx WITH SUPERUSER LOGIN PASSWORD '$password';"
sudo -u postgres /usr/pgsql-9.4/bin/psql -c "CREATE ROLE freeswitch WITH SUPERUSER LOGIN PASSWORD '$password';"
sudo -u postgres /usr/pgsql-9.4/bin/psql -c "GRANT ALL PRIVILEGES ON DATABASE fusionpbx to fusionpbx;"
sudo -u postgres /usr/pgsql-9.4/bin/psql -c "GRANT ALL PRIVILEGES ON DATABASE freeswitch to fusionpbx;"
sudo -u postgres /usr/pgsql-9.4/bin/psql -c "GRANT ALL PRIVILEGES ON DATABASE freeswitch to freeswitch;"
#ALTER USER fusionpbx WITH PASSWORD 'newpassword';
cd $cwd

verbose "PostgreSQL 9.4 installed"