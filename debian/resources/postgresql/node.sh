#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ../config.sh

#set the date
now=$(date +%Y-%m-%d)

#show this server's addresses
server_address=$(hostname -I);
echo "This Server Address: $server_address"

#nodes addresses
read -p "Enter all Node IP Addresses: " nodes

#determine whether to add iptable rules
read -p 'Add iptable rules (y,n): ' iptables_add

#settings summary
echo "-----------------------------";
echo " Summary";
echo "-----------------------------";
echo "All Node IP Addresses: $nodes";
echo "Add iptable rules: $iptables_add";
echo "";

#verify
read -p 'Is the information correct (y,n): ' verified 
if [ .$verified != ."y" ]; then
	echo "Goodbye";
	exit 0;
fi

#iptables rules
if [ .$iptables_add = ."y" ]; then
	for node in $nodes; do
		/usr/sbin/iptables -A INPUT -j ACCEPT -p tcp --dport 5432 -s ${node}/32
		/usr/sbin/iptables -A INPUT -j ACCEPT -p tcp --dport 22000 -s ${node}/32
	done
	apt-get remove iptables-persistent -y
	echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
	echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
	apt-get install -y iptables-persistent
	systemctl restart fail2ban
fi

#setup ssl
sed -i /etc/postgresql/$database_version/main/postgresql.conf -e s:'snakeoil.key:snakeoil-postgres.key:'
cp /etc/ssl/private/ssl-cert-snakeoil.key /etc/ssl/private/ssl-cert-snakeoil-postgres.key
chown postgres:postgres /etc/ssl/private/ssl-cert-snakeoil-postgres.key
chmod 600 /etc/ssl/private/ssl-cert-snakeoil-postgres.key

#postgresql.conf - append settings
cp /etc/postgresql/$database_version/main/postgresql.conf /etc/postgresql/$database_version/main/postgresql.conf-$now
#cat ../postgresql/postgresql.conf > /etc/postgresql/$database_version/main/postgresql.conf
echo "#listen_addresses = '127.0.0.1,xxx.xxx.xxx.xxx'" >> /etc/postgresql/$database_version/main/postgresql.conf
echo "listen_addresses = '*'" >> /etc/postgresql/$database_version/main/postgresql.conf
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

#reload the config
sudo -u postgres psql -p $database_port -c "SELECT pg_reload_conf();"

#restart postgres
systemctl restart postgresql

#set the working directory
cwd=$(pwd)
cd /tmp

#add extension pgcrypto
if [ .$group_create = ."n" ]; then
	sudo -u postgres psql -d freeswitch -c "CREATE EXTENSION pgcrypto;";
fi

#message to user
echo "Completed"
