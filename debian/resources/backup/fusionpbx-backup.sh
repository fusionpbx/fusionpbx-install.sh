#!/bin/sh

#export PGPASSWORD="zzz"
db_host=127.0.0.1
db_port=5432

now=$(date +%Y-%m-%d)
mkdir -p /var/backups/fusionpbx/postgresql

echo "Backup Started"

#delete postgres backups
find /var/backups/fusionpbx/postgresql/fusionpbx_pgsql* -mtime +4 -exec rm {} \;

#delete the main backup
find /var/backups/fusionpbx/*.tgz -mtime +2 -exec rm {} \;

#backup the database
pg_dump --verbose -Fc --host=$db_host --port=$db_port -U fusionpbx fusionpbx --schema=public -f /var/backups/fusionpbx/postgresql/fusionpbx_pgsql_$now.sql

#package
tar -zvcf /var/backups/fusionpbx/backup_$now.tgz /var/backups/fusionpbx/postgresql/fusionpbx_pgsql_$now.sql /var/www/fusionpbx /usr/share/freeswitch/scripts /var/lib/freeswitch/storage /var/lib/freeswitch/recordings /etc/fusionpbx /etc/freeswitch

#source
#tar -zvcf /var/backups/fusionpbx/backup_$now.tgz /var/backups/fusionpbx/postgresql/fusionpbx_pgsql_$now.sql /var/www/fusionpbx /usr/local/freeswitch/scripts /usr/local/freeswitch/storage /usr/local/freeswitch/recordings /etc/fusionpbx /usr/local/freeswitch/conf

echo "Backup Completed"
