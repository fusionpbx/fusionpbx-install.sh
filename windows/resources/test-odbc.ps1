Function Test-ODBC([string]$DSN,[string]$username,[string]$password) {
	$connection_string = "DSN=$DSN;"
	if ($username) {
		$connection_string += "username=$username;"
	}
	if ($password) {
		$connection_string += "password=$password;"
	}
	$conn = New-Object System.Data.Odbc.OdbcConnection
	$conn.ConnectionString = $connection_string
	$conn.open()
	$result = ($conn.State -eq "Open")
	if ($result) {
		$conn.Close()
	}
	return $result
}
