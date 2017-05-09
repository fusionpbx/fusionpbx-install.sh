#!/bin/sh

#
# This doesn't seem to be currently in use (2017.04.25).
#

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ../config.sh

#set the date
now=$(date +%Y-%m-%d)

#set the database password
if [ .$database_password = .'random' ]; then
        database_password=$(dd if=/dev/urandom bs=1 count=20 2>/dev/null | base64 | sed 's/[=\+//]//g')
fi

#show this server's addresses
server_address=$(hostname -I);
echo "This Server Address: $server_address"

#nodes addresses
read -p "Enter all Node IP Addresses: " nodes

#request the domain and email
read -p 'Create Group (true/false): ' group_create
if [ .$group_create = .true ]; then
	read -p 'Enter this Nodes Address: ' node_1;
else
	read -p 'Join using node already in group: ' node_1;
	read -p 'Enter this Nodes Address: ' node_2;
fi

#settings summary
echo "-----------------------------";
echo " Summary";
echo "-----------------------------";
echo "Create Group: $group_create";
echo "All Node IP Addresses: $nodes";
if [ .$group_create = .true ]; then
	echo "This Nodes Address: $node_1";
else
	echo "Join using node in group: $node_1;"
	echo "This Node Address: $node_2";
fi
echo "";

#verify
read -p 'Is the information correct (y/n): ' verified 
if [ .$verified != ."y" ]; then
	echo "Goodbye";
	exit 0;
fi

#iptables rules
for node in $nodes; do
        iptables -A INPUT -j ACCEPT -p tcp --dport 5432 -s ${node}/32
        iptables -A INPUT -j ACCEPT -p tcp --dport 8080 -s ${node}/32
done
apt-get remove iptables-persistent -y
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
apt-get install -y iptables-persistent

#setup ssl
sed -i /etc/postgresql/9.4/main/postgresql.conf -e s:'snakeoil.key:snakeoil-postgres.key:'
cp /etc/ssl/private/ssl-cert-snakeoil.key /etc/ssl/private/ssl-cert-snakeoil-postgres.key
chown postgres:postgres /etc/ssl/private/ssl-cert-snakeoil-postgres.key
chmod 600 /etc/ssl/private/ssl-cert-snakeoil-postgres.key

#postgresql.conf - append settings
cp /etc/postgresql/9.4/main/postgresql.conf /etc/postgresql/9.4/main/postgresql.conf-$now
cat ../postgresql/postgresql.conf > /etc/postgresql/9.4/main/postgresql.conf

#pg_hba.conf - append settings
cp /etc/postgresql/9.4/main/pg_hba.conf /etc/postgresql/9.4/main/pg_hba.conf-$now
cat ../postgresql/pg_hba.conf > /etc/postgresql/9.4/main/pg_hba.conf
#chmod 640 /etc/postgresql/9.4/main/pg_hba.conf
#chown -R postgres:postgres /etc/postgresql/9.4/main
for node in $nodes; do
        echo "hostssl all             all            ${node}/32              trust" >> /etc/postgresql/9.4/main/pg_hba.conf
        echo "hostssl replication     postgres       ${node}/32              trust" >> /etc/postgresql/9.4/main/pg_hba.conf
done

#reload configuration
systemctl daemon-reload

#restart postgres
systemctl restart postgresql

#set the working directory
cwd=$(pwd)
cd /tmp

#add the database users and databases
sudo -u postgres psql -c "CREATE DATABASE fusionpbx;";
sudo -u postgres psql -c "CREATE DATABASE freeswitch;";

#add the users and grant permissions
sudo -u postgres psql -c "CREATE ROLE fusionpbx WITH SUPERUSER LOGIN PASSWORD '$database_password';"
sudo -u postgres psql -c "CREATE ROLE freeswitch WITH SUPERUSER LOGIN PASSWORD '$database_password';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE fusionpbx to fusionpbx;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE freeswitch to fusionpbx;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE freeswitch to freeswitch;"

#add the postgres extensions
sudo -u postgres psql -d fusionpbx -c "CREATE EXTENSION btree_gist;";
sudo -u postgres psql -d fusionpbx -c "CREATE EXTENSION bdr;";
sudo -u postgres psql -d freeswitch -c "CREATE EXTENSION btree_gist;";
sudo -u postgres psql -d freeswitch -c "CREATE EXTENSION bdr;";

#add master nodes
if [ .$group_create = .true ]; then
	#add first node
	sudo -u postgres psql -d fusionpbx -c "SELECT bdr.bdr_group_create(local_node_name := '$node_1', node_external_dsn := 'host=$node_1 port=5432 dbname=fusionpbx connect_timeout=10 keepalives_idle=5 keepalives_interval=1 sslmode=require');";
	sudo -u postgres psql -d freeswitch -c "SELECT bdr.bdr_group_create(local_node_name := '$node_1', node_external_dsn := 'host=$node_1 port=5432 dbname=freeswitch connect_timeout=10 keepalives_idle=5 keepalives_interval=1 sslmode=require');";
else
	#add additional master nodes
	sudo -u postgres psql -d fusionpbx -c "SELECT bdr.bdr_group_join(local_node_name := '$node_2', node_external_dsn := 'host=$node_2 port=5432 dbname=fusionpbx connect_timeout=10 keepalives_idle=5 keepalives_interval=1', join_using_dsn := 'host=$node_1 port=5432 dbname=fusionpbx connect_timeout=10 keepalives_idle=5 keepalives_interval=1 sslmode=require');";
	sudo -u postgres psql -d freeswitch -c "SELECT bdr.bdr_group_join(local_node_name := '$node_2', node_external_dsn := 'host=$node_2 port=5432 dbname=freeswitch connect_timeout=10 keepalives_idle=5 keepalives_interval=1', join_using_dsn := 'host=$node_1 port=5432 dbname=freeswitch connect_timeout=10 keepalives_idle=5 keepalives_interval=1 sslmode=require');";
fi

#load the freeswitch database
#sudo -u postgres psql -d freeswitch -f /var/www/fusionpbx/resources/install/sql/switch.sql -L /tmp/switch-sql.log

#sleeping
if [ .$group_create = .false ]; then
	echo "Sleeping for 15 seconds";
	for i in `seq 1 15`; do
		echo $i
		sleep 1
	done
fi

#add extension pgcrypto
if [ .$group_create = .false ]; then
	sudo -u postgres psql -d freeswitch -c "CREATE EXTENSION pgcrypto;";
fi

#message to user
echo "Completed"
