#!/bin/sh

#send a message
echo "Install PostgreSQL Client"

#Install postgres repo
lsb_release -c |grep -i jessie > /dev/null
if [ $? -eq 0 ]; then
cat > "/etc/apt/sources.list.d/pgsql-pgdg.list" << DELIM
deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main
DELIM
else
cat > "/etc/apt/sources.list.d/pgsql-pgdg.list" << DELIM
deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main
DELIM
fi

#Postgres
echo "Install PostgreSQL and create the database and users\n"
for i in postgresql-client-9.5 php5-pgsql ;do sudo apt-get -y install --force-yes "${i}"; done
