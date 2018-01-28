
Function Start-ODBC([string]$query) {
	. .\resources\get-database_password
	$conn = New-Object System.Data.Odbc.OdbcConnection
	$conn.ConnectionString = "DSN=fusionpbx;username=fusionpbx;password=$database_password"
	$conn.open()
	if ($conn.State -eq "Open") {
		$cmd = New-object System.Data.Odbc.OdbcCommand($query,$conn)
		$cmd.ExecuteScalar()
		$conn.Close()
	}
}
#Start-ODBC "select username from v_users"