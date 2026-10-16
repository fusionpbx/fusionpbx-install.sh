#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh

#count the users
admin_users=$(sudo -u postgres psql fusionpbx -Atc "select count(*) from v_users JOIN v_user_groups USING (domain_uuid) where username='$system_username' and group_name = 'superadmin'")

if [ .$admin_users = .'0' ]; then
	error "i could not find the user '$system_username' in the database, check your resources/config.sh is correct"
elif [ .$admin_users = .'' ]; then
	error "something went wrong, see errors above";
else
	admin_uuids=$(sudo -u postgres psql fusionpbx -Atc "select v_users.user_uuid from v_users JOIN v_user_groups USING (domain_uuid) where username='$system_username' and group_name = 'superadmin'")
	for admin_uuid in $admin_uuids; do
		user_salt=$(/usr/bin/php /var/www/fusionpbx/resources/uuid.php);
		if [ .$system_password = .'random' ]; then
			user_password=$(dd if=/dev/urandom bs=1 count=12 2>/dev/null | base64 | sed 's/[=\+//]//g')
		else
			user_password=$system_password
		fi
		password_hash=$(php -r "echo md5('$user_salt$user_password');");
		sudo -u postgres psql fusionpbx -c "update v_users SET password='$password_hash', salt='$user_salt' where user_uuid='$admin_uuid'"
		admin_domain=$(sudo -u postgres psql fusionpbx -Atc "select domain_name from v_users JOIN v_domains USING (domain_uuid) where username='$system_username'")
		verbose "   $system_username@$admin_domain has had it's password reset."
		verbose "      password: $user_password"
	done	
fi
