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
read -p 'Add ip address to pg_hba (y/n): ' pg_hba_add

#settings summary
echo "-----------------------------";
echo " Summary";
echo "-----------------------------";
echo "All Node IP Addresses: $nodes";
echo "Add ip addresses to pg_hba: $pg_hba_add";
echo "";

#verify
read -p 'Is the information correct (y/n): ' verified 
if [ .$verified != ."y" ]; then
	echo "Goodbye";
	exit 0;
fi

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

#message to user
echo "Completed"
