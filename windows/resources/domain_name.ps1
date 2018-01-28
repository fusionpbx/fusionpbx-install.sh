#Set the domain name
$cert = Get-ChildItem -Path cert:\LocalMachine\My | Where-Object -Property Subject -Like "CN=${env:COMPUTERNAME}*" | Sort-Object NotAfter | Select-Object -Last 1
if ( $cert -and ($domain_name -eq "hostname") ) {
	$domain_name = $cert.Subject.Substring(3)
}
elseif ($domain_name -eq "hostname") {
	$domain_name = $env:COMPUTERNAME
	#$dns = [System.Net.Dns]::GetHostByName(($env:computerName))
	#$domain_name = $dns.HostName
	#$dns.addresslist.IPAddressToString
}
else {
	$domain_name = [System.Net.Dns]::GetHostByName(($env:computerName)).AddressList.IPAddressToString
}
Write-Host "Domain Name is $domain_name"