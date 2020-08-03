#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh

#set the current working directory
cwd=$(pwd)

if [ .$nginx_enabled = .'true' ]; then

	#database details
	database_username=fusionpbx
	if [ .$database_password = .'random' ]; then
		database_password=$(cat /dev/random | env LC_CTYPE=C tr -dc a-zA-Z0-9 | head -c 20)
	fi

	#allow the script to use the new password
	export PGPASSWORD=$database_password

	#install the dependencies
	pkg install --yes sudo 

	#update the database password
	sudo -u postgres psql -c "ALTER USER fusionpbx WITH PASSWORD '$database_password';"
	sudo -u postgres psql -c "ALTER USER freeswitch WITH PASSWORD '$database_password';"

	#add the config.php
	mkdir -p /etc/fusionpbx
	chown -R www:www /etc/fusionpbx
	cp fusionpbx/config.php /etc/fusionpbx
	sed -i' ' -e s:"{database_host}:$database_host:" /etc/fusionpbx/config.php
	sed -i' ' -e s:'{database_username}:fusionpbx:' /etc/fusionpbx/config.php
	sed -i' ' -e s:"{database_password}:$database_password:" /etc/fusionpbx/config.php

	#add the database schema
	cd /usr/local/www/fusionpbx && /usr/local/bin/php /usr/local/www/fusionpbx/core/upgrade/upgrade_schema.php > /dev/null 2>&1

	#get the primary interface name
	if [ .$interface_name = .'auto' ]; then
		interface_name=$(ifconfig -l | awk '{print $1}')
		if [ .$interface_name = .'lo0' ]; then
			interface_name=$(ifconfig -l | awk '{print $2}')
		fi
	fi

	#get the ip address
	local_ip_v4=$(ifconfig $interface_name | grep 'inet ' | awk '{print $2}')

	#get the server hostname
	if [ .$domain_name = .'hostname' ]; then
		domain_name=$(hostname -f)
	fi

	#get the ip address
	if [ .$domain_name = .'ip_address' ]; then
		domain_name=$(ifconfig $interface_name | grep 'inet ' | awk '{print $2}')
	fi

	#get the domain uuid
	domain_uuid=$(uuidgen);

	#add the domain name
	psql --host=$database_host --port=$database_port --username=$database_username -c "insert into v_domains (domain_uuid, domain_name, domain_enabled) values('$domain_uuid', '$domain_name', 'true');"

	#app defaults
	cd /usr/local/www/fusionpbx && /usr/local/bin/php /usr/local/www/fusionpbx/core/upgrade/upgrade_domains.php

	#add the user
	user_uuid=$(/usr/local/bin/php /usr/local/www/fusionpbx/resources/uuid.php);
	user_salt=$(/usr/local/bin/php /usr/local/www/fusionpbx/resources/uuid.php);
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
	user_group_uuid=$(/usr/local/bin/php /usr/local/www/fusionpbx/resources/uuid.php);
	group_name=superadmin
	if [ .$system_branch = .'master' ]; then
		psql --host=$database_host --port=$database_port --username=$database_username -c "insert into v_user_groups (user_group_uuid, domain_uuid, group_name, group_uuid, user_uuid) values('$user_group_uuid', '$domain_uuid', '$group_name', '$group_uuid', '$user_uuid');"
	else
		psql --host=$database_host --port=$database_port --username=$database_username -c "insert into v_group_users (group_user_uuid, domain_uuid, group_name, group_uuid, user_uuid) values('$user_group_uuid', '$domain_uuid', '$group_name', '$group_uuid', '$user_uuid');"
	fi
	#add the local_ip_v4 address
	psql --host=$database_host --port=$database_port --username=$database_username -t -c "insert into v_vars (var_uuid, var_name, var_value, var_category, var_order, var_enabled) values ('4507f7a9-2cbb-40a6-8799-f8f168082585', 'local_ip_v4', '$local_ip_v4', 'Defaults', '0', 'true');";

	#app defaults
	if [ .$nginx_enabled = .'true' ]; then
		cd /usr/local/www/fusionpbx && php /usr/local/www/fusionpbx/core/upgrade/upgrade_domains.php
	fi

	#reset the current working directory
	cd $cwd
fi

if [ .$switch_enabled = .'true' ]; then

	#update xml_cdr url, user and password
	xml_cdr_username=$(cat /dev/random | env LC_CTYPE=C tr -dc a-zA-Z0-9 | head -c 20)
	xml_cdr_password=$(cat /dev/random | env LC_CTYPE=C tr -dc a-zA-Z0-9 | head -c 20)

	#set the conf directory
	if [ .$switch_source = ."package" ]; then
		conf_dir="/usr/local/etc/freeswitch";
	fi
	if [ .$switch_source = ."source" ]; then
		conf_dir="/usr/local/freeswitch/conf";
	fi

	#update the xml_cdr.conf.xml file
	sed -i' ' -e s:"{v_http_protocol}:http:" $conf_dir/autoload_configs/xml_cdr.conf.xml
	sed -i' ' -e s:"{domain_name}:127.0.0.1:" $conf_dir/autoload_configs/xml_cdr.conf.xml
	sed -i' ' -e s:"{v_project_path}::" $conf_dir/autoload_configs/xml_cdr.conf.xml
	sed -i' ' -e s:"{v_user}:$xml_cdr_username:" $conf_dir/autoload_configs/xml_cdr.conf.xml
	sed -i' ' -e s:"{v_pass}:$xml_cdr_password:" $conf_dir/autoload_configs/xml_cdr.conf.xml

	#stop freeswitch
	#service freeswitch restart

	#install monit.sh
	if [ .$monit_enabled = .'true' ]; then
		. ./monit.sh
	fi
fi

#welcome message
echo ""
echo ""
verbose "Installation has completed."
echo ""
if [ .$nginx_enabled = .'true' ]; then
	echo "   Use a web browser to login."
	echo "      domain name: http://$domain_name"
	echo "      username: $user_name"
	echo "      password: $user_password"
 	echo ""
	echo "   The domain name in the browser is used by default as part of the authentication."
	echo "   If you need to login to a different domain then use username@domain."
	echo "      username: $user_name@$domain_name";
	echo ""
fi
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
