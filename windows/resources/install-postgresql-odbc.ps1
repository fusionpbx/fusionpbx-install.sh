Function Install-PostgresODBC() {
    . .\resources\get-cpu.ps1
	. .\resources\get-link.ps1
	. .\resources\get-file.ps1
    . .\resources\expand-zip.ps1
	. .\resources\get-database_password

	if (Get-Installed-App "psqlODBC*") {
		Write-Host PostgreSQL ODBC is already installed
		return
	}

	$cpu = Get-CPU
	if ($cpu -eq "x86") {
		$url = "https://ftp.postgresql.org/pub/odbc/versions/msi/psqlodbc_10_01_0000-x86.zip"
	}
	else {
		$url = "https://ftp.postgresql.org/pub/odbc/versions/msi/psqlodbc_10_01_0000-x64.zip"
	}
	Write-Host Download ODBC from $url -ForegroundColor Cyan
	$filename = Get-File $url -Force
	Expand-ZIP $filename

	Write-Host Install postgresql-odbc
	$filename = Get-Item psqlodbc*.exe
	if ($filename) {
		Start-Process $filename -Wait
	}

	$filename = Get-Item psqlodbc*.msi
	if ($filename) {
		Start-Process msiexec "/i $filename /passive /qb" -Wait
	}

	#if ((Get-Command Get-OdbcDsn)) { # -ErrorAction SilentlyContinue
		#Get or create DSN
	#	$dsn = Get-OdbcDsn FusionPBX -ErrorAction SilentlyContinue
	#	Remove-OdbcDsn FusionPBX -DsnType System
	#	if ($dsn.length -eq 0) {
		    # Get ODBC Driver name
	#	    $driver = (Get-OdbcDriver -Name "PostgreSQL Unicode*").Name
	#	    $dsn = Add-OdbcDsn -DsnType System -Name fusionpbx -DriverName $driver -SetPropertyValue "servername=localhost","port=5432","database=fusionpbx","GssAuthUseGSS=0"
	#	}
	#	$dsn | Set-OdbcDsn -SetPropertyValue Username=postgres
	#    $dsn | Set-OdbcDsn -SetPropertyValue password=$database_password
	#}
	#else {
		# Configure DSN with ODBC Administrator
		Write-Host The ODBC Administrator window will open. -ForegroundColor Yellow
		if ($cpu -eq "x86") {
			$driver="PostgreSQL Unicode"
		}
		else {
			$driver="PostgreSQL Unicode(x64)"
		}
		#ODBCCONF.EXE /Lv dsn_log.txt CONFIGSYSDSN "$driver" "DSN=fusionpbx|server=localhost|port=5432|database=fusionpbx|Username=postgres|password=$database_password"
		ODBCCONF.EXE /Lv dsn_log.txt CONFIGSYSDSN "$driver" "DSN=fusionpbx|server=localhost|port=5432|database=fusionpbx|Username=postgres|password=$database_password|GssAuthUseGSS=false"
	#}
	#Start-Process odbcad32.exe -Wait
}

#. .\resources\get-database_password
#Test-ODBC fusionpbx postgres $database_password