Function Start-PSQL([string]$command) {
	$location = Get-Location
	Set-Location "C:\Program Files\PostgreSQL\10\bin"
	$result = .\psql.exe --username=postgres -c "$command" 
	Set-Location $location
	return $result
}