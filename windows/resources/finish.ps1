#Includes
. .\resources\config.ps1
. .\resources\write-log.ps1
. .\resources\domain_name.ps1
. .\resources\get-database_password.ps1
. .\resources\get-system_password.ps1
. .\resources\start-pgsql.ps1

#Temp Permissions

$Acl = Get-Acl "C:/inetpub/FusionPBX"

$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("EVERYONE", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")

$Acl.SetAccessRule($Ar)
Set-Acl "C:/inetpub/FusionPBX" $Acl

$psql = "C:\Program Files\PostgreSQL\10\bin\psql.exe -U fusionpbx"


#add the config.php
Copy-Item "./resources/fusionpbx/config.php" "C:/inetpub/FusionPBX/resources"
$filename = "C:/inetpub/FusionPBX/resources/config.php"
(Get-Content $filename) -replace "{database_username}","fusionpbx" `
				-replace "{database_password}",$database_password | Out-File $filename

#add the database schema
Start-Process "C:\Program Files\PHP\v7.1\php.exe" "C:/inetpub/FusionPBX/core/upgrade/upgrade_schema.php"

#get the domain_uuid
[string]$domain_uuid = [System.Guid]::NewGuid()

#add the domain name
"C:\Program Files\PostgreSQL\10\bin\psql.exe -U fusionpbx insert into v_domains (domain_uuid, domain_name, domain_enabled) values('$domain_uuid', '$domain_name', 'true');"

#app defaults
Start-Process "C:\Program Files\PHP\v7.1\php.exe" "C:/inetpub/FusionPBX/core/upgrade/upgrade_domains.php"

#add the user
[string]$user_uuid = [System.Guid]::NewGuid()
[string]$user_salt = [System.Guid]::NewGuid()
$user_name=$system_username
if ($system_password -eq 'random') {
	$user_password = New-Password 20
}
else {
	$user_password=$system_password
}
$password_hash = ."C:\Program Files\PHP\v7.1\php.exe" "-r echo md5('$user_salt$user_password');"
"$psql insert into v_users (user_uuid, domain_uuid, username, password, salt, user_enabled) values('$user_uuid', '$domain_uuid', '$user_name', '$password_hash', '$user_salt', 'true');"

#get the superadmin group_uuid
"$psql select group_uuid from v_groups where group_name = 'superadmin';"

#add the user to the group
[string]$user_group_uuid = [System.Guid]::NewGuid()
$group_name="superadmin"
"$psql insert into v_user_groups (user_group_uuid, domain_uuid, group_name, group_uuid, user_uuid) values('$user_group_uuid', '$domain_uuid', '$group_name', '$group_uuid', '$user_uuid');"

#app defaults
Start-Process "C:\Program Files\PHP\v7.1\php.exe" "C:/inetpub/FusionPBX/core/upgrade/upgrade_domains.php"

#Permissions back to readonly
$Acl = Get-Acl "C:/inetpub/FusionPBX"

$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("EVERYONE", "Read", "ContainerInherit,ObjectInherit", "None", "Allow")

$Acl.SetAccessRule($Ar)
Set-Acl "C:/inetpub/FusionPBX" $Acl

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

Write-Log "      Press any key to close this window."
Write-Log "      Please copy the important info first."

cmd /c pause | out-null
