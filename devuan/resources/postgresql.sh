#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh
. ./environment.sh

#send a message
verbose "Installing PostgreSQL"

#use the system database repo for arm
if [ .$cpu_architecture = .'arm' ]; then
    database_repo="sip247"
fi

apt-get install -q -y sudo

#included in the distribution
if [ ."$database_repo" = ."system" ]; then
	apt-get install -q -y postgresql
fi

#postgres official repository
if [ ."$database_repo" = ."official" ]; then
    verbose "Using official repos"
	echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main' > /etc/apt/sources.list.d/pgdg.list
	wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
	apt-get -q update && apt-get upgrade -y
	apt-get install -y postgresql
fi

#Add PostgreSQL and BDR REPO
if [ ."$database_repo" = ."2ndquadrant" ]; then
    verbose "Using 2ndquadrant.com repos"
	echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main'  >> /etc/apt/sources.list.d/postgresql.list
	echo 'deb http://packages.2ndquadrant.com/bdr/apt/ jessie-2ndquadrant main' >> /etc/apt/sources.list.d/2ndquadrant.list
	wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -
	wget --quiet -O - http://packages.2ndquadrant.com/bdr/apt/AA7A6805.asc | apt-key add -
	apt-get -q update && apt-get upgrade -y
	apt-get install -y postgresql-bdr-9.4 postgresql-bdr-9.4-bdr-plugin postgresql-bdr-contrib-9.4
fi

#sip247 arm repository
if [ ."$database_repo" = ."sip247" ]; then
        echo 'deb http://repo.sip247.com/debian/postgresql-armhf jessie main' > /etc/apt/sources.list.d/pgsql-sip247.list
        wget --quiet -O - http://repo.sip247.com/debian/sip247.com.gpg.key | apt-key add -
        apt-get -q update && apt-get upgrade -y
        apt-get install -y postgresql
fi

service postgresql restart
