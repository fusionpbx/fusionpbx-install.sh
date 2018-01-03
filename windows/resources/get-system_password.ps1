#System Password
if ($system_password -eq 'random') {
	$system_password = New-Password 20
}
elseif ($system_password -eq '') {
	$system_password = Read-Host -Prompt "Enter system password"
}