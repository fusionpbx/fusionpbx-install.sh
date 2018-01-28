#!/bin/sh

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
read -p 'Create Group (y/n): ' group_create
if [ .$group_create = ."y" ]; then
	read -p 'Enter this Nodes Address: ' node_1;
else
	read -p 'Join using node already in group: ' node_1;
	read -p 'Enter this Nodes Address: ' node_2;
fi

#determine which database to replicate
read -p 'Replicate the FusionPBX Database (y/n): ' system_replicate

#determine which database to replicate
read -p 'Replicate the FreeSWITCH Database (y/n): ' switch_replicate

#determine whether to add iptable rules
read -p 'Add iptable rules (y/n): ' iptables_add

#settings summary
echo "-----------------------------";
echo " Summary";
echo "-----------------------------";
echo "Create Group: $group_create";
echo "All Node IP Addresses: $nodes";
if [ .$group_create = ."y" ]; then
	echo "This Nodes Address: $node_1";
else
	echo "Join using node in group: $node_1";
	echo "This Node Address: $node_2";
fi
echo "Replicate the FusionPBX Database: $system_replicate";
echo "Replicate the FreeSWITCH Database: $switch_replicate";
echo "Add iptable rules: $iptables_add";
echo "";

#verify
read -p 'Is the information correct (y/n): ' verified 
if [ .$verified != ."y" ]; then
	echo "Goodbye";
	exit 0;
fi

#add the 2ndquadrant repo
if [ .$database_version = ."9.6" ]; then
	echo 'deb http://packages.2ndquadrant.com/bdr/apt/ jessie-2ndquadrant main' > /etc/apt/sources.list.d/2ndquadrant.list
	/usr/bin/wget --quiet -O - http://packages.2ndquadrant.com/bdr/apt/AA7A6805.asc | apt-key add -
	apt-get update && apt-get upgrade -y
	apt-get install -y --force-yes sudo postgresql-9.6-bdr-plugin
fi

#iptables rules
if [ .$iptables_add = ."y" ]; then
	for node in $nodes; do
		iptables -A INPUT -j ACCEPT -p tcp --dport 5432 -s ${node}/32
		iptables -A INPUT -j ACCEPT -p tcp --dport 22000 -s ${node}/32
	done
	apt-get remove iptables-persistent -y --force-yes
	echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
	echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
	apt-get install -y --force-yes iptables-persistent
fi

#setup ssl
sed -i /etc/postgresql/$database_version/main/postgresql.conf -e s:'snakeoil.key:snakeoil-postgres.key:'
cp /etc/ssl/private/ssl-cert-snakeoil.key /etc/ssl/private/ssl-cert-snakeoil-postgres.key
chown postgres:postgres /etc/ssl/private/ssl-cert-snakeoil-postgres.key
chmod 600 /etc/ssl/private/ssl-cert-snakeoil-postgres.key

#postgresql.conf - append settings
cp /etc/postgresql/$database_version/main/postgresql.conf /etc/postgresql/$database_version/main/postgresql.conf-$now
#cat ../postgresql/postgresql.conf > /etc/postgresql/$database_version/main/postgresql.conf
echo "listen_addresses = '*'" >> /etc/postgresql/$database_version/main/postgresql.conf
echo "#listen_addresses = '127.0.0.1,xxx.xxx.xxx.xxx'" >> /etc/postgresql/$database_version/main/postgresql.conf
echo "shared_preload_libraries = 'bdr'" >> /etc/postgresql/$database_version/main/postgresql.conf
echo "wal_level = 'logical'" >> /etc/postgresql/$database_version/main/postgresql.conf
echo "track_commit_timestamp = on" >> /etc/postgresql/$database_version/main/postgresql.conf
echo "max_connections = 100" >> /etc/postgresql/$database_version/main/postgresql.conf
echo "max_wal_senders = 10" >> /etc/postgresql/$database_version/main/postgresql.conf
echo "max_replication_slots = 48" >> /etc/postgresql/$database_version/main/postgresql.conf
echo "max_worker_processes = 48" >> /etc/postgresql/$database_version/main/postgresql.conf

#pg_hba.conf - append settings
cp /etc/postgresql/$database_version/main/pg_hba.conf /etc/postgresql/$database_version/main/pg_hba.conf-$now
cat ../postgresql/pg_hba.conf > /etc/postgresql/$database_version/main/pg_hba.conf
#chmod 640 /etc/postgresql/$database_version/main/pg_hba.conf
#chown -R postgres:postgres /etc/postgresql/$database_version/main
echo "host    all             all            127.0.0.1/32              trust" >> /etc/postgresql/$database_version/main/pg_hba.conf
echo "hostssl all             all            127.0.0.1/32              trust" >> /etc/postgresql/$database_version/main/pg_hba.conf
echo "hostssl replication     postgres       127.0.0.1/32              trust" >> /etc/postgresql/$database_version/main/pg_hba.conf
for node in $nodes; do
        echo "host    all             all            ${node}/32              trust" >> /etc/postgresql/$database_version/main/pg_hba.conf
        echo "hostssl all             all            ${node}/32              trust" >> /etc/postgresql/$database_version/main/pg_hba.conf
        echo "hostssl replication     postgres       ${node}/32              trust" >> /etc/postgresql/$database_version/main/pg_hba.conf
done

#reload configuration
systemctl daemon-reload

#restart postgres
service postgresql restart

#set the working directory
cwd=$(pwd)
cd /tmp

#add the postgres extensions
sudo -u postgres psql -d fusionpbx -c "CREATE EXTENSION btree_gist;";
sudo -u postgres psql -d fusionpbx -c "CREATE EXTENSION bdr;";
sudo -u postgres psql -d freeswitch -c "CREATE EXTENSION btree_gist;";
sudo -u postgres psql -d freeswitch -c "CREATE EXTENSION bdr;";

#add master nodes
if [ .$group_create = ."y" ]; then
	#add first node
	if [ .$system_replicate = ."y" ]; then
		sudo -u postgres psql -d fusionpbx -c "SELECT bdr.bdr_group_create(local_node_name := '$node_1', node_external_dsn := 'host=$node_1 port=5432 dbname=fusionpbx connect_timeout=10 keepalives_idle=5 keepalives_interval=1 sslmode=require');";
	fi
	if [ .$switch_replicate = ."y" ]; then
		sudo -u postgres psql -d freeswitch -c "SELECT bdr.bdr_group_create(local_node_name := '$node_1', node_external_dsn := 'host=$node_1 port=5432 dbname=freeswitch connect_timeout=10 keepalives_idle=5 keepalives_interval=1 sslmode=require');";
	fi
else
	#add additional master nodes
	if [ .$system_replicate = ."y" ]; then
		sudo -u postgres psql -d fusionpbx -c "SELECT bdr.bdr_group_join(local_node_name := '$node_2', node_external_dsn := 'host=$node_2 port=5432 dbname=fusionpbx connect_timeout=10 keepalives_idle=5 keepalives_interval=1', join_using_dsn := 'host=$node_1 port=5432 dbname=fusionpbx connect_timeout=10 keepalives_idle=5 keepalives_interval=1 sslmode=require');";
	fi
	if [ .$switch_replicate = ."y" ]; then
		sudo -u postgres psql -d freeswitch -c "SELECT bdr.bdr_group_join(local_node_name := '$node_2', node_external_dsn := 'host=$node_2 port=5432 dbname=freeswitch connect_timeout=10 keepalives_idle=5 keepalives_interval=1', join_using_dsn := 'host=$node_1 port=5432 dbname=freeswitch connect_timeout=10 keepalives_idle=5 keepalives_interval=1 sslmode=require');";
	fi
fi

#load the freeswitch database
#sudo -u postgres psql -d freeswitch -f /var/www/fusionpbx/resources/install/sql/switch.sql -L /tmp/switch-sql.log

#sleeping
if [ .$group_create = ."n" ]; then
	echo "Sleeping for 15 seconds";
	for i in `seq 1 15`; do
		echo $i
		sleep 1
	done
fi

#add extension pgcrypto
if [ .$group_create = ."n" ]; then
	sudo -u postgres psql -d freeswitch -c "CREATE EXTENSION pgcrypto;";
fi

#message to user
echo "Completed"
