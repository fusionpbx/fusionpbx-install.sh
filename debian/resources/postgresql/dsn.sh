#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ../config.sh

#set the date
now=$(date +%Y-%m-%d)

#get the database password
if [ .$database_password = .'random' ]; then
	read -p "Enter the database password: " database_password
fi

#whether to load the schema
read -p "Auto create schemas (y/n): " auto_create_schema

#whether to load the schema
read -p "Load schema with primary keys (y/n): " load_schema

#set PGPASSWORD
export PGPASSWORD=$database_password

#disable auto create schemas
if [ .$auto_create_schema = ."n" ]; then
	sed -i /etc/freeswitch/autoload_configs/switch.conf.xml -e s:'<!-- <param name="auto-create-schemas" value="true"/> -->:<param name="auto-create-schemas" value="false"/>:'
fi

#load the schema
if [ .$load_schema = ."y" ]; then
	sudo -u postgres psql -d freeswitch -c "create extension pgcrypto;";
	sudo -u postgres psql -d freeswitch -f /var/www/fusionpbx/resources/install/sql/switch.sql -L /tmp/schema.log;
fi

#enable odbc-dsn in the xml
sed -i /etc/freeswitch/autoload_configs/db.conf.xml -e s:'<!--<param name="odbc-dsn" value="$${dsn}"/>-->:<param name="odbc-dsn" value="$${dsn}"/>:'
sed -i /etc/freeswitch/autoload_configs/fifo.conf.xml -e s:'<!--<param name="odbc-dsn" value="$${dsn}"/>-->:<param name="odbc-dsn" value="$${dsn}"/>:'
sed -i /etc/freeswitch/autoload_configs/switch.conf.xml -e s:'<!-- <param name="core-db-dsn" value="$${dsn}" /> -->:<param name="core-db-dsn" value="$${dsn}" />:'

#enable odbc-dsn in the sip profiles
sudo -u postgres psql -d fusionpbx -c "update v_sip_profile_settings set sip_profile_setting_enabled = 'true' where sip_profile_setting_name = 'odbc-dsn';";

#add the dsn variables
sudo -u postgres psql -d fusionpbx -c "insert into v_vars (var_uuid, var_name, var_value, var_cat, var_enabled, var_order, var_description, var_hostname) values ('785d7013-1152-4a44-aa15-28336d9b36f9', 'dsn_system', 'pgsql://hostaddr=127.0.0.1 dbname=fusionpbx user=fusionpbx password=$database_password options=', 'DSN', 'true', '0', null, null);";
sudo -u postgres psql -d fusionpbx -c "insert into v_vars (var_uuid, var_name, var_value, var_cat, var_enabled, var_order, var_description, var_hostname) values ('0170e737-b453-40ea-99f2-f1375474e5ce', 'dsn', 'pgsql://hostaddr=127.0.0.1 dbname=freeswitch user=fusionpbx password=$database_password options=', 'DSN', 'true', '0', null, null);";
sudo -u postgres psql -d fusionpbx -c "insert into v_vars (var_uuid, var_name, var_value, var_cat, var_enabled, var_order, var_description, var_hostname) values ('32e3e364-a8ef-4fe0-9d02-c652d5122bbf', 'dsn_callcenter', 'sqlite:///var/lib/freeswitch/db/callcenter.db', 'DSN', 'true', '0', null, null);";

#add the 
echo "<!-- DSN -->" >> /etc/freeswitch/vars.xml
echo "<X-PRE-PROCESS cmd=\"set\" data=\"dsn_system=pgsql://hostaddr=127.0.0.1 dbname=fusionpbx user=fusionpbx password=$database_password options=\" />" >> /etc/freeswitch/vars.xml
echo "<X-PRE-PROCESS cmd=\"set\" data=\"dsn=pgsql://hostaddr=127.0.0.1 dbname=freeswitch user=fusionpbx password=$database_password options=\" />" >> /etc/freeswitch/vars.xml
echo "<X-PRE-PROCESS cmd=\"set\" data=\"dsn_callcenter=sqlite:///var/lib/freeswitch/db/callcenter.db\" />" >> /etc/freeswitch/vars.xml

#remove the sqlite database files
dbs="/var/lib/freeswitch/db/core.db /var/lib/freeswitch/db/fifo.db /var/lib/freeswitch/db/call_limit.db /var/lib/freeswitch/db/sofia_reg_*"
for db in ${dbs};
do
  if [ -f $db ]; then
    echo "Deleting $db";
    rm $db
  fi
done

#flush memcache
/usr/bin/fs_cli -x 'memcache flush'

#restart freeswitch
service freeswitch restart
