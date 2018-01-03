#includes
. .\resources\new-password.ps1

#Database Password
if ($env:PGPASSWORD) {
	$database_password = $env:PGPASSWORD
}
if ($database_password -eq 'random') {
	$database_password = New-Password 20
}
elseif ($database_password -eq '') {
	$database_password = Read-Host -Prompt "Enter database superuser (postgres) password"
}
#Set DB password
$env:PGPASSWORD = "$database_password"