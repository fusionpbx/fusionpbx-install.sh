
Function New-Password([int32]$length) {
	$password = ""
	$chars = "abcdefghijkmnopqrstuvwxyzABCEFGHJKLMNPQRSTUVWXYZ23456789".ToCharArray()
	1..$length | ForEach {  $password += $chars | Get-Random }
	return $password
}