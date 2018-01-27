Function Install-PostgreSQL() {

	. .\resources\get-file.ps1
	. .\resources\get-database_password.ps1
	. .\resources\start-pgsql.ps1
    . .\resources\get-installed-app.ps1

	if (Get-Installed-App "PostgreSQL*") {
		Write-Host PostgreSQL is already installed
		return
	}
	if ($env:PROCESSOR_ARCHITECTURE -eq "x86") {
		$url = "https://get.enterprisedb.com/postgresql/postgresql-10.1-3-windows.exe"
	}
	else {
		$url = "https://get.enterprisedb.com/postgresql/postgresql-10.1-3-windows-x64.exe"
	}

	Write-Host Download PostgreSQL from $url -ForegroundColor Cyan
	$filename = Get-File $url
	Write-Host Install Postgresql -ForegroundColor Cyan

	Start-Process $filename "--mode unattended --superpassword $database_password" -Wait
	#Get-Service postgre*

	Write-Host "Create the database and users" -ForegroundColor Cyan
	Start-PSQL "CREATE DATABASE fusionpbx;";
	Start-PSQL "CREATE DATABASE freeswitch;";
	Start-PSQL "CREATE ROLE fusionpbx WITH SUPERUSER LOGIN PASSWORD '$database_password';"
	Start-PSQL "CREATE ROLE freeswitch WITH SUPERUSER LOGIN PASSWORD '$database_password';"
	Start-PSQL "GRANT ALL PRIVILEGES ON DATABASE fusionpbx to fusionpbx;"
	Start-PSQL "GRANT ALL PRIVILEGES ON DATABASE freeswitch to fusionpbx;"
	Start-PSQL "GRANT ALL PRIVILEGES ON DATABASE freeswitch to freeswitch;"
	
	#move pg_hba.conf
    	Move-Item "C:\Program Files\PostgreSQL\10\data\pg_hba.conf" "C:\Program Files\PostgreSQL\10\data\BAK_pg_hba.conf"
    	Copy-Item ".\resources\postgresql\pg_hba.conf" "C:\Program Files\PostgreSQL\10\data\" -recurse

    	#reload 
    	C:\Windows\system32\cscript.exe //NoLogo "C:\Program Files\PostgreSQL\10\scripts\serverctl.vbs" reload
	
}
