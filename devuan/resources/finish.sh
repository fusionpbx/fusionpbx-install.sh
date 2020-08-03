#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh
. ./environment.sh

#database details
database_host=127.0.0.1
database_port=5432
database_username=fusionpbx
if [ .$database_password = .'random' ]; then
    database_password="$(tr -dc A-Za-z0-9 < /dev/urandom | head -c 20 | xargs)"
fi

verbose "Create the database and users"

#
# Install the database backup scripts
#

cp backup/fusionpbx-backup.sh /etc/cron.daily
chmod 755 /etc/cron.daily/fusionpbx-backup.sh
sed -i "s/zzz/${database_password}/g" /etc/cron.daily/fusionpbx-backup.sh

#
# Install the maintenance script
#

cp backup/fusionpbx-maintenance.sh /etc/cron.daily
chmod 755 /etc/cron.daily/fusionpbx-maintenance.sh
sed -i "s/zzz/${database_password}/g" /etc/cron.daily/fusionpbx-maintenance.sh

#
# Move to /tmp to prevent a red herring error when running sudo with psql
#

cwd=$(pwd)
cd /tmp

#
# I'm not sure why we would do this when the databases don't exist yet.
#

#sudo -u postgres psql -d fusionpbx -c "DROP SCHEMA public cascade;";
#sudo -u postgres psql -d fusionpbx -c "CREATE SCHEMA public;";

sudo -u postgres psql -c "CREATE DATABASE fusionpbx;";
sudo -u postgres psql -c "CREATE ROLE fusionpbx WITH SUPERUSER LOGIN PASSWORD '$database_password';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE fusionpbx to fusionpbx;"

#
# Maybe the freeswitch will use the freeswitch database in the future?
# Right now it's configured to use SQLite.
# So we will comment this out.
#

#sudo -u postgres psql -c "CREATE DATABASE freeswitch;";
#sudo -u postgres psql -c "CREATE ROLE freeswitch WITH SUPERUSER LOGIN PASSWORD '$password';"
#sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE freeswitch to fusionpbx;"
#sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE freeswitch to freeswitch;"

cd $cwd

#add the config.php
mkdir -p /etc/fusionpbx
chown -R www-data:www-data /etc/fusionpbx
cp fusionpbx/config.php /etc/fusionpbx
sed -i /etc/fusionpbx/config.php -e s:"{database_host}:$database_host:"
sed -i /etc/fusionpbx/config.php -e s:'{database_username}:fusionpbx:'
sed -i /etc/fusionpbx/config.php -e s:"{database_password}:$database_password:"

#add the database schema
cd /var/www/fusionpbx && php /var/www/fusionpbx/core/upgrade/upgrade_schema.php > /dev/null 2>&1

#get the server hostname
#domain_name=$(hostname -f)

#get the ip address
domain_name=$(hostname -I | cut -d ' ' -f1)

#get a domain_uuid
domain_uuid=$(/usr/bin/php /var/www/fusionpbx/resources/uuid.php);

#allow the script to use the new password
export PGPASSWORD=$database_password

#add the domain name
psql --host=$database_host --port=$database_port --username=$database_username -c "insert into v_domains (domain_uuid, domain_name, domain_enabled) values('$domain_uuid', '$domain_name', 'true');"

#app defaults - this is needed here otherwise group superadmin will not exist for "get the superadmin group_uuid" *
cd /var/www/fusionpbx && php /var/www/fusionpbx/core/upgrade/upgrade_domains.php

#add the user
user_uuid=$(/usr/bin/php /var/www/fusionpbx/resources/uuid.php);
user_salt=$(/usr/bin/php /var/www/fusionpbx/resources/uuid.php);
user_name=$system_username
if [ .$system_password = .'random' ]; then
	user_password="$(tr -dc A-Za-z0-9 < /dev/urandom | head -c 12 | xargs)"
else
	user_password=$system_password
fi

password_hash=$(php -r "echo md5('$user_salt$user_password');");

psql --host=$database_host --port=$database_port --username=$database_username -t -c "insert into v_users (user_uuid, domain_uuid, username, password, salt, user_enabled) values('$user_uuid', '$domain_uuid', '$user_name', '$password_hash', '$user_salt', 'true');"

#get the superadmin group_uuid *
group_uuid=$(psql --host=$database_host --port=$database_port --username=$database_username -t -c "select group_uuid from v_groups where group_name = 'superadmin';");
group_uuid=$(echo $group_uuid | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//')

#add the user to the group
user_group_uuid=$(/usr/bin/php /var/www/fusionpbx/resources/uuid.php);
group_name=superadmin
if [ .$system_branch = .'master' ]; then
	psql --host=$database_host --port=$database_port --username=$database_username -c "insert into v_user_groups (user_group_uuid, domain_uuid, group_name, group_uuid, user_uuid) values('$user_group_uuid', '$domain_uuid', '$group_name', '$group_uuid', '$user_uuid');"
else
	psql --host=$database_host --port=$database_port --username=$database_username -c "insert into v_group_users (group_user_uuid, domain_uuid, group_name, group_uuid, user_uuid) values('$user_group_uuid', '$domain_uuid', '$group_name', '$group_uuid', '$user_uuid');"
fi	
#update xml_cdr url, user and password
xml_cdr_username=$(dd if=/dev/urandom bs=1 count=12 2>/dev/null | base64 | sed 's/[=\+//]//g')
xml_cdr_password=$(dd if=/dev/urandom bs=1 count=12 2>/dev/null | base64 | sed 's/[=\+//]//g')
sed -i /etc/freeswitch/autoload_configs/xml_cdr.conf.xml -e s:"{v_http_protocol}:http:"
sed -i /etc/freeswitch/autoload_configs/xml_cdr.conf.xml -e s:"{domain_name}:127.0.0.1:"
sed -i /etc/freeswitch/autoload_configs/xml_cdr.conf.xml -e s:"{v_project_path}::"
sed -i /etc/freeswitch/autoload_configs/xml_cdr.conf.xml -e s:"{v_user}:$xml_cdr_username:"
sed -i /etc/freeswitch/autoload_configs/xml_cdr.conf.xml -e s:"{v_pass}:$xml_cdr_password:"

#app defaults - not sure if this needs to be executed again
cd /var/www/fusionpbx && php /var/www/fusionpbx/core/upgrade/upgrade_domains.php

/usr/sbin/service freeswitch restart

#welcome message
echo ""
echo ""
verbose "Installation has completed."
echo ""
echo "   Use a web browser to login."
echo "      domain name: https://$domain_name"
echo "      username: $user_name"
echo "      password: $user_password"
echo ""
echo "   The domain name in the browser is used by default as part of the authentication."
echo "   If you need to login to a different domain then use username@domain."
echo "      username: $user_name@$domain_name";
echo ""
echo "   Official FusionPBX Training"
echo "      Fastest way to learn FusionPBX. For more information https://www.fusionpbx.com."
echo "      Available online and in person. Includes documentation and recording."
echo ""
echo "      Location:               Online"
echo "      Admin Training:          TBA"
echo "      Advanced Training:       TBA"
echo "      Continuing Education:    27th August 2020 (1 Day)"
echo "      Timezone:               https://www.timeanddate.com/weather/usa/idaho"
echo ""
echo "   Additional information."
echo "      https://fusionpbx.com/members.php"
echo "      https://fusionpbx.com/training.php"
echo "      https://fusionpbx.com/support.php"
echo "      https://www.fusionpbx.com"
echo "      http://docs.fusionpbx.com"
echo ""
