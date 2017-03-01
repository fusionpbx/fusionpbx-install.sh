#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./colors.sh
. ./arguments.sh

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

#get the server hostname
#domain_name=$(hostname -f)

#get the ip address
domain_name=$(hostname -I | cut -d ' ' -f1)

#get a domain_uuid
#try to find existed and enabled rows count
domain_uuid_count=$(psql --host=$database_host --port=$database_port --username=$database_username -t -c "select count(domain_uuid) from v_domains where domain_name='$domain_name' and domain_enabled='true';");
domain_uuid_count=$(echo $domain_uuid_count | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//')
verbose 'Found domain_uuid_count = ['$domain_uuid_count']'

if [ .$domain_uuid_count = .'0' ]; then
	#generate uuid
	domain_uuid=$(/usr/bin/php /var/www/fusionpbx/resources/uuid.php);
	#add the domain name
	psql --host=$database_host --port=$database_port --username=$database_username -c "insert into v_domains (domain_uuid, domain_name, domain_enabled) values('$domain_uuid', '$domain_name', 'true');"
else
	#dump all rows existed no matter enabled or not
	psql --host=$database_host --port=$database_port --username=$database_username -c "select * from v_domains where domain_name='$domain_name' order by domain_uuid;"
	#get the first existed and enabled uuid
	domain_uuid=$(psql --host=$database_host --port=$database_port --username=$database_username -t -c "select domain_uuid from v_domains where domain_name='$domain_name' and domain_enabled='true' order by domain_uuid limit 1 offset 0;");
	domain_uuid=$(echo $domain_uuid | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//')
	#there can be only one
	#only one uuid with this name enabled of course
	if [ $$domain_uuid_count -ge 2 ]; then
		error "Duplicate enabled domains with name '$domain_name' are detected"
		warning "We won't do such modification by default, please check and fix fusionpbx db by yourself"
		verbose "Example command to leave only one row enabled with domain_uuid = ['$domain_uuid'] and domain_name = ['$domain_name']"
		echo "psql --host=$database_host --port=$database_port --username=$database_username -c \"update v_domains set domain_enabled='false' where domain_name='$domain_name' and domain_enabled='true' and not domain_uuid='$domain_uuid';\""
	fi
fi

verbose 'Will be used domain_uuid = ['$domain_uuid'] with domain_name = ['$domain_name']'

#app defaults
cd /var/www/fusionpbx && php /var/www/fusionpbx/core/upgrade/upgrade_domains.php

#prepare user info
user_name=admin
user_password=$(dd if=/dev/urandom bs=1 count=12 2>/dev/null | base64 | sed 's/[=\+//]//g')
user_salt=$(/usr/bin/php /var/www/fusionpbx/resources/uuid.php);
password_hash=$(php -r "echo md5('$user_salt$user_password');");

#get a user_uuid
#try to find existed and enabled rows count
user_uuid_count=$(psql --host=$database_host --port=$database_port --username=$database_username -t -c "select count(user_uuid) from v_users where username='$user_name' and user_enabled='true' and domain_uuid='$domain_uuid';");
user_uuid_count=$(echo $user_uuid_count | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//')
verbose 'Found user_uuid_count = ['$user_uuid_count']'

if [ .$user_uuid_count = .'0' ]; then
	#generate uuid
	user_uuid=$(/usr/bin/php /var/www/fusionpbx/resources/uuid.php);
	#add the user
	psql --host=$database_host --port=$database_port --username=$database_username -t -c "insert into v_users (user_uuid, domain_uuid, username, password, salt, user_enabled) values('$user_uuid', '$domain_uuid', '$user_name', '$password_hash', '$user_salt', 'true');"
else
	#dump all rows existed no matter enabled or not
	psql --host=$database_host --port=$database_port --username=$database_username -c "select user_uuid, domain_uuid, username, user_enabled from v_users where username='$user_name' and domain_uuid='$domain_uuid' order by user_uuid;"
	#get the first existed and enabled uuid
	user_uuid=$(psql --host=$database_host --port=$database_port --username=$database_username -t -c "select user_uuid from v_users where username='$user_name' and user_enabled='true' and domain_uuid='$domain_uuid' order by user_uuid limit 1 offset 0;");
	user_uuid=$(echo $user_uuid | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//')
	#there can be only one
	#only one uuid with this name enabled of course
	if [ $user_uuid_count -ge 2 ]; then
		error "Duplicate accounts with name '$user_name' for domain with name '$domain_name' are detected"
		warning "We won't do such modification by default, please check and fix fusionpbx db by yourself"
		verbose "Example command to leave only one row enabled with user_uuid = ['$user_uuid'] for domain_uuid = ['$domain_uuid'] and domain_name = ['$domain_name']"
		echo "psql --host=$database_host --port=$database_port --username=$database_username -c \"update v_users set user_enabled='false' where username='$user_name' and user_enabled='true' and domain_uuid='$domain_uuid' and not user_uuid='$user_uuid';\""
	fi
	#update user password
	psql --host=$database_host --port=$database_port --username=$database_username -c "update v_users set password='$password_hash', salt='$user_salt' where username='$user_name' and user_enabled='true' and user_uuid='$user_uuid';"
fi

verbose 'Will be used user_uuid = ['$user_uuid'] with user_name = ['$user_name']'

#get the superadmin group_uuid
group_name=superadmin
group_uuid=$(psql --host=$database_host --port=$database_port --username=$database_username -t -c "select group_uuid from v_groups where group_name = '$group_name';");
group_uuid=$(echo $group_uuid | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//')

#get a group_user_uuid
#try to find existed rows count
group_user_uuid_count=$(psql --host=$database_host --port=$database_port --username=$database_username -t -c "select count(group_user_uuid) from v_group_users where domain_uuid='$domain_uuid' and group_name='$group_name' and group_uuid='$group_uuid' and user_uuid='$user_uuid';");
group_user_uuid_count=$(echo $group_user_uuid_count | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//')
verbose 'Found group_user_uuid_count = ['$group_user_uuid_count']'

if [ .$group_user_uuid_count = .'0' ]; then
	#generate uuid
	group_user_uuid=$(/usr/bin/php /var/www/fusionpbx/resources/uuid.php);
	#add the user to the group
	psql --host=$database_host --port=$database_port --username=$database_username -c "insert into v_group_users (group_user_uuid, domain_uuid, group_name, group_uuid, user_uuid) values('$group_user_uuid', '$domain_uuid', '$group_name', '$group_uuid', '$user_uuid');"
else
	#dump all rows existed no matter enabled or not
	psql --host=$database_host --port=$database_port --username=$database_username -c "select * from v_group_users where domain_uuid='$domain_uuid' and group_name='$group_name' and group_uuid='$group_uuid' and user_uuid='$user_uuid';"
	#get the first existed and enabled uuid
	group_user_uuid=$(psql --host=$database_host --port=$database_port --username=$database_username -t -c "select group_user_uuid from v_group_users where domain_uuid='$domain_uuid' and group_name='$group_name' and group_uuid='$group_uuid' and user_uuid='$user_uuid' limit 1 offset 0;");
	group_user_uuid=$(echo $group_user_uuid | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//')
	#there can be only one
	#only one uuid with this name enabled of course
	if [ $group_user_uuid_count -ge 2 ]; then
		error "Duplicate rows in v_group_users for user name '$user_name' and group name '$group_name' for domain with name '$domain_name' are detected"
		warning "We won't do such modification by default, please check and fix fusionpbx db by yourself"
		verbose "Example command to leave only one row enabled with user_uuid = ['$user_uuid'] and group_user_uuid = ['$group_user_uuid'] for domain_uuid = ['$domain_uuid'] and domain_name = ['$domain_name']"
		echo "psql --host=$database_host --port=$database_port --username=$database_username -c \"delete from v_group_users where domain_uuid='$domain_uuid' and group_name='$group_name' and group_uuid='$group_uuid' and user_uuid='$user_uuid' and not group_user_uuid='$group_user_uuid';\""
	fi
fi

#update xml_cdr url, user and password
xml_cdr_username=$(dd if=/dev/urandom bs=1 count=12 2>/dev/null | base64 | sed 's/[=\+//]//g')
xml_cdr_password=$(dd if=/dev/urandom bs=1 count=12 2>/dev/null | base64 | sed 's/[=\+//]//g')
sed -i /etc/freeswitch/autoload_configs/xml_cdr.conf.xml -e s:"{v_http_protocol}:http:"
sed -i /etc/freeswitch/autoload_configs/xml_cdr.conf.xml -e s:"{domain_name}:127.0.0.1:"
sed -i /etc/freeswitch/autoload_configs/xml_cdr.conf.xml -e s:"{v_project_path}::"
sed -i /etc/freeswitch/autoload_configs/xml_cdr.conf.xml -e s:"{v_user}:$xml_cdr_username:"
sed -i /etc/freeswitch/autoload_configs/xml_cdr.conf.xml -e s:"{v_pass}:$xml_cdr_password:"

#app defaults
cd /var/www/fusionpbx && php /var/www/fusionpbx/core/upgrade/upgrade_domains.php

#restart freeswitch
/bin/systemctl daemon-reload
/bin/systemctl restart freeswitch

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
echo "      Admin Training    24 - 26 Jan (3 Days)"
echo "      Advanced Training 31 Jan - Feb 2 (3 Days)"
echo "      Timezone: https://www.timeanddate.com/worldclock/usa/boise"
echo "      For more info visit https://www.fusionpbx.com"
echo ""
echo "   Additional information."
echo "      https://fusionpbx.com/support.php"
echo "      https://www.fusionpbx.com"
echo "      http://docs.fusionpbx.com"
echo ""



