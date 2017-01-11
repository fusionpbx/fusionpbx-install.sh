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

#database details
database_host=127.0.0.1
database_port=5432
database_username=fusionpbx
database_password=$(dd if=/dev/urandom bs=1 count=20 2>/dev/null | base64 | sed 's/[=\+//]//g')

#allow the script to use the new password
export PGPASSWORD=$database_password

#update the database password
sudo -u postgres psql -c "ALTER USER fusionpbx WITH PASSWORD '$database_password';"
sudo -u postgres psql -c "ALTER USER freeswitch WITH PASSWORD '$database_password';"

#add the config.php
mkdir -p /etc/fusionpbx
chown -R www-data:www-data /etc/fusionpbx
cp fusionpbx/config.php /etc/fusionpbx
sed -i /etc/fusionpbx/config.php -e s:'{database_username}:fusionpbx:'
sed -i /etc/fusionpbx/config.php -e s:"{database_password}:$database_password:"

#add the database schema
cd /var/www/fusionpbx && php /var/www/fusionpbx/core/upgrade/upgrade_schema.php > /dev/null 2>&1

#add the domain
domain_name=$(hostname -f)
domain_uuid=$(/usr/bin/php /var/www/fusionpbx/resources/uuid.php);
psql --host=$database_host --port=$database_port --username=$database_username -c "insert into v_domains (domain_uuid, domain_name, domain_enabled) values('$domain_uuid', '$domain_name', 'true');"

#app defaults
cd /var/www/fusionpbx && php /var/www/fusionpbx/core/upgrade/upgrade_domains.php

#add the user
user_uuid=$(/usr/bin/php /var/www/fusionpbx/resources/uuid.php);
user_salt=$(/usr/bin/php /var/www/fusionpbx/resources/uuid.php);
user_name=admin
user_password=$(dd if=/dev/urandom bs=1 count=12 2>/dev/null | base64 | sed 's/[=\+//]//g')
password_hash=$(php -r "echo md5('$user_salt$user_password');");
psql --host=$database_host --port=$database_port --username=$database_username -t -c "insert into v_users (user_uuid, domain_uuid, username, password, salt, user_enabled) values('$user_uuid', '$domain_uuid', '$user_name', '$password_hash', '$user_salt', 'true');"

#get the superadmin group_uuid
group_uuid=$(psql --host=$database_host --port=$database_port --username=$database_username -t -c "select group_uuid from v_groups where group_name = 'superadmin';");
group_uuid=$(echo $group_uuid | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//')

#add the user to the group
group_user_uuid=$(/usr/bin/php /var/www/fusionpbx/resources/uuid.php);
group_name=superadmin
psql --host=$database_host --port=$database_port --username=$database_username -c "insert into v_group_users (group_user_uuid, domain_uuid, group_name, group_uuid, user_uuid) values('$group_user_uuid', '$domain_uuid', '$group_name', '$group_uuid', '$user_uuid');"

#welcome message
echo ""
echo ""
verbose "Installation has completed."
echo ""
echo "   Use a web browser to login."
echo "      location: https://$domain_name"
echo "      username: $user_name"
echo "      password: $user_password"
echo ""
echo "   If your server hostname is not a fully qualified domain name";
echo "   Then login with your ip address and $user_name@$domain_name";
echo ""
echo "   For additional information use the following links.";
echo "      https://www.fusionpbx.com"
echo "      http://docs.fusionpbx.com"
echo ""
