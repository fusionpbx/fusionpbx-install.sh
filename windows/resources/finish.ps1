#Includes
. .\resources\config.ps1
. .\resources\write-log.ps1
. .\resources\domain_name.ps1
. .\resources\get-database_password.ps1
. .\resources\get-system_password.ps1
. .\resources\start-pgsql.ps1

#add the config.php
Copy-Item "fusionpbx/config.php" "$system_directory/resources"
$filename = "$system_directory/resources/config.php"
(Get-Content $filename) -replace "{database_username}","fusionpbx" `
				-replace "{database_password}",$database_password | Out-File $filename

#add the database schema
."C:\Program Files\PHP\v7.1\php.exe" "$system_directory/core/upgrade/upgrade_schema.php"

#get the domain_uuid
[string]$domain_uuid = [System.Guid]::NewGuid()

#add the domain name
Start-PSQL "insert into v_domains (domain_uuid, domain_name, domain_enabled) values('$domain_uuid', '$domain_name', 'true');"

#app defaults
."C:\Program Files\PHP\v7.1\php.exe" "$system_directory/core/upgrade/upgrade_domains.php"

#add the user
[string]$user_uuid = [System.Guid]::NewGuid()
[string]$user_salt = [System.Guid]::NewGuid()
user_name=$system_username
if ($system_password -eq 'random') {
	$user_password = New-Password 20
}
else {
	$user_password=$system_password
}
$password_hash = ."C:\Program Files\PHP\v7.1\php.exe" "-r echo md5('$user_salt$user_password');"
Start-PSQL "insert into v_users (user_uuid, domain_uuid, username, password, salt, user_enabled) values('$user_uuid', '$domain_uuid', '$user_name', '$password_hash', '$user_salt', 'true');"

#get the superadmin group_uuid
group_uuid=Start-PSQL "select group_uuid from v_groups where group_name = 'superadmin';"

#add the user to the group
[string]$group_user_uuid = [System.Guid]::NewGuid()
$group_name="superadmin"
Start-PSQL "insert into v_group_users (group_user_uuid, domain_uuid, group_name, group_uuid, user_uuid) values('$group_user_uuid', '$domain_uuid', '$group_name', '$group_uuid', '$user_uuid');"

#app defaults
."C:\Program Files\PHP\v7.1\php.exe" "$system_directory/core/upgrade/upgrade_domains.php"

#welcome message
Write-Log ""
Write-Log "   Use a web browser to continue setup."
Write-Log "      domain name: https://$domain_name"
Write-Log "      username: $system_username"
Write-Log "      password: $system_password"
Write-Log ""
Write-Log "   The domain name in the browser is used by default as part of the authentication."
Write-Log "   If you need to login to a different domain then use username@domain."
Write-Log "      username: $system_username@$domain_name";
Write-Log ""
Write-Log "   Database:"
Write-Log "      username: postgres"
Write-Log "      password: $database_password"
Write-Log ""
Write-Log "   Additional information."
Write-Log "      https://fusionpbx.com/support.php"
Write-Log "      https://www.fusionpbx.com"
Write-Log "      http://docs.fusionpbx.com"

#Start login page
#Start-Process http://$domain_name
