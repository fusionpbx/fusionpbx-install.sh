#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

. ./colors.sh
. ./arguments.sh

#send a message
verbose "Installing FusionPBX"

#install dependencies
apt-get install -y --force-yes vim git dbus haveged ssl-cert
apt-get install -y --force-yes ghostscript libtiff5-dev libtiff-tools

if [ $USE_SYSTEM_MASTER = true ]; then
	verbose "Using master"
	BRANCH=""
else
	FUSION_MAJOR=$(git ls-remote --heads https://github.com/fusionpbx/fusionpbx.git | cut -d/ -f 3 | grep -P '^\d+\.\d+' | sort | tail -n 1 | cut -d. -f1)
	FUSION_MINOR=$(git ls-remote --tags https://github.com/fusionpbx/fusionpbx.git $FUSION_MAJOR.* | cut -d/ -f3 |  grep -P '^\d+\.\d+' | sort | tail -n 1 | cut -d. -f2)
	FUSION_VERSION=$FUSION_MAJOR.$FUSION_MINOR
	verbose "Using version $FUSION_VERSION"
	BRANCH="-b $FUSION_VERSION"
fi

#get the source code
git clone $BRANCH https://github.com/fusionpbx/fusionpbx.git /var/www/fusionpbx
chown -R www-data:www-data /var/www/fusionpbx
chmod -R 755 /var/www/fusionpbx/secure

#create the /etc/fusionpbx directory and copy the config.php into it
#mkdir -p /etc/fusionpbx
#chown -R www-data:www-data /etc/fusionpbx
#cp fusionpbx/config.php /etc/fusionpbx
#sed -i /etc/fusionpbx/config.php -e s:'{database_username}:fusionpbx:'
#sed -i /etc/fusionpbx/config.php -e s:'{database_password}:1234:'

#add the database schema
#cd /var/www/fusionpbx && php /var/www/fusionpbx/core/upgrade/upgrade_schema.php > /dev/null 2>&1

#get the source code
git clone $BRANCH https://github.com/fusionpbx/fusionpbx.git /var/www/fusionpbx
chown -R www-data:www-data /var/www/fusionpbx
chmod -R 755 /var/www/fusionpbx/secure

#database_password=1234
#export PGPASSWORD=$database_password
#mkdir -p /etc/fusionpbx
#chown -R www-data:www-data /etc/fusionpbx
#cp fusionpbx/config.php /etc/fusionpbx
#sed -i /etc/fusionpbx/config.php -e s:'{database_username}:fusionpbx:'
#sed -i /etc/fusionpbx/config.php -e s:"{database_password}:$database_password:"
#domain_name=$(hostname -f)
#domain_uuid=$(/usr/bin/php /var/www/fusionpbx/resources/uuid.php);
#psql --host=127.0.0.1 --port=5432 --username=fusionpbx -c "insert into v_domains (domain_uuid, domain_name, domain_enabled) values('$domain_uuid', '$domain_name', 'true');"
#cd /var/www/fusionpbx && php /var/www/fusionpbx/core/upgrade/upgrade_domains.php
