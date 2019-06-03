#!/bin/sh

#database settings
db_host=127.0.0.1
db_port=5432

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ../config.sh

#set the database password
export PGPASSWORD=$database_password

#set the date
now=$(date +%Y-%m-%d)

#make sure the backup directory exists
mkdir -p /var/backups/fusionpbx/postgresql

#backup the database
pg_dump --verbose -Fc --host=$db_host --port=$db_port -U fusionpbx fusionpbx --schema=public -f /var/backups/fusionpbx/postgresql/fusionpbx_auto_$now.sql

#empty the fusionpbx database
sudo -u postgres psql -d fusionpbx -c "drop schema public cascade;";
sudo -u postgres psql -d fusionpbx -c "create schema public;";
