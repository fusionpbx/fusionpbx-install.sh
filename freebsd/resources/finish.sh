#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh

#database details
database_host=127.0.0.1
database_port=5432
database_username=fusionpbx
if [ .$database_password = .'random' ]; then
	database_password=$(cat /dev/random | env LC_CTYPE=C tr -dc a-zA-Z0-9 | head -c 20)
fi

#allow the script to use the new password
export PGPASSWORD=$database_password

#update the database password
sudo -u postgres psql -c "ALTER USER fusionpbx WITH PASSWORD '$database_password';"
sudo -u postgres psql -c "ALTER USER freeswitch WITH PASSWORD '$database_password';"

#add the config.php
mkdir -p /etc/fusionpbx
chown -R www-data:www-data /etc/fusionpbx
cp fusionpbx/config.php /etc/fusionpbx
sed -i' ' -e s:'{database_username}:fusionpbx:' /etc/fusionpbx/config.php
sed -i' ' -e s:"{database_password}:$database_password:" /etc/fusionpbx/config.php

#add the database schema
cd /usr/local/www/fusionpbx && php /usr/local/www/fusionpbx/core/upgrade/upgrade_schema.php > /dev/null 2>&1

#get the server hostname
#domain_name=$(hostname -f)

#get the interface name
interface_name=$(ifconfig | pcregrep -M -o '^[^\t:]+:([^\n]|\n\t)*status: active' | egrep -o -m 1 '^[^\t:]+')

#get the ip address
domain_name=$(ifconfig $interface_name | grep 'inet ' | awk '{print $2}')

#get a domain_uuid
domain_uuid=$(/usr/bin/php /usr/local/www/fusionpbx/resources/uuid.php);

#add the domain name
psql --host=$database_host --port=$database_port --username=$database_username -c "insert into v_domains (domain_uuid, domain_name, domain_enabled) values('$domain_uuid', '$domain_name', 'true');"

#app defaults
cd /usr/local/www/fusionpbx && php /usr/local/www/fusionpbx/core/upgrade/upgrade_domains.php

#add the user
user_uuid=$(/usr/bin/php /usr/local/www/fusionpbx/resources/uuid.php);
user_salt=$(/usr/bin/php /usr/local/www/fusionpbx/resources/uuid.php);
user_name=$system_username
if [ .$system_password = .'random' ]; then
	user_password=$(cat /dev/random | env LC_CTYPE=C tr -dc a-zA-Z0-9 | head -c 20)
else
	user_password=$system_password
fi
password_hash=$(php -r "echo md5('$user_salt$user_password');");
psql --host=$database_host --port=$database_port --username=$database_username -t -c "insert into v_users (user_uuid, domain_uuid, username, password, salt, user_enabled) values('$user_uuid', '$domain_uuid', '$user_name', '$password_hash', '$user_salt', 'true');"

#get the superadmin group_uuid
group_uuid=$(psql --host=$database_host --port=$database_port --username=$database_username -t -c "select group_uuid from v_groups where group_name = 'superadmin';");
group_uuid=$(echo $group_uuid | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//')

#add the user to the group
group_user_uuid=$(/usr/bin/php /usr/local/www/fusionpbx/resources/uuid.php);
group_name=superadmin
psql --host=$database_host --port=$database_port --username=$database_username -c "insert into v_group_users (group_user_uuid, domain_uuid, group_name, group_uuid, user_uuid) values('$group_user_uuid', '$domain_uuid', '$group_name', '$group_uuid', '$user_uuid');"

#update xml_cdr url, user and password
xml_cdr_username=$(cat /dev/random | env LC_CTYPE=C tr -dc a-zA-Z0-9 | head -c 20)
xml_cdr_password=$(cat /dev/random | env LC_CTYPE=C tr -dc a-zA-Z0-9 | head -c 20)
sed -i' ' -e s:"{v_http_protocol}:http:" /usr/local/freeswitch/conf/autoload_configs/xml_cdr.conf.xml
sed -i' ' -e s:"{domain_name}:127.0.0.1:" /usr/local/freeswitch/conf/autoload_configs/xml_cdr.conf.xml
sed -i' ' -e s:"{v_project_path}::" /usr/local/freeswitch/conf/autoload_configs/xml_cdr.conf.xml
sed -i' ' -e s:"{v_user}:$xml_cdr_username:" /usr/local/freeswitch/conf/autoload_configs/xml_cdr.conf.xml
sed -i' ' -e s:"{v_pass}:$xml_cdr_password:" /usr/local/freeswitch/conf/autoload_configs/xml_cdr.conf.xml

#app defaults
cd /usr/local/www/fusionpbx && php /usr/local/www/fusionpbx/core/upgrade/upgrade_domains.php

#restart freeswitch
service freeswitch restart

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
echo "      Admin Training    27 - 28 March (2 Days)"
echo "      Advanced Training 29 - 30 March (2 Days)"
echo "      Timezone: https://www.timeanddate.com/worldclock/usa/boise"
echo "      Available online and in person. Includes documentation and recording."
echo ""
echo "   Additional information."
echo "      https://fusionpbx.com/support.php"
echo "      https://www.fusionpbx.com"
echo "      http://docs.fusionpbx.com"
echo ""
