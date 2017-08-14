# FusionPBX Settings
$domain_name = "hostname"          # hostname, ip_address or a custom value
$system_username = "admin"           # default username admin
$system_password = "random"          # random or a custom value
$system_branch = "master"            # master, stable
$system_directory = "${env:SystemDrive}\inetpub\FusionPBX"

# FreeSWITCH Settings
#$switch_branch = "stable"            # master, stable
#$switch_source = $false             # true or false
#$switch_package = $true             # true or false

# Database Settings
$database_password = "random"        # random or a custom value
#$database_backup = $false           # true or false

# Web server
$php_version = 7                   # PHP version 5 or 7
$web_server = "IIS"                 # nginx or IIS
$iis_identity = "LocalSystem"       # localSystem or NetworkService

# Download file to current folder using default or provided name. Return saved file name
Function Get-File([string]$url, [string]$filename) {
    #Get filename from path
    if ($filename.Length -eq 0) {
        $filename = Split-Path -Path $url -Leaf
    }
    #Download if local copy doesn't exist
    if (-not (Test-Path $filename)) {
        Invoke-WebRequest $url -OutFile $filename
    }
    return $filename
}

# Get page with links, filter, and select latest version using pattern. Return file download URL.
Function Get-Link([string]$url, [string]$pattern) {
    $link = (Invoke-WebRequest $url).Links | Where-Object {$_.href -like $pattern} | Select-Object -Last 1
    Write-Host $link.href -ForegroundColor Gray
    
    #Use System.URI to combine url parts
    $uri = New-Object -TypeName System.URI -ArgumentList ([System.URI]$url),($link.href)
    return $uri.AbsoluteUri
}

Function Get-CPU() {
    if ($env:PROCESSOR_ARCHITECTURE -eq "x86") {
        Return "x86"
    }
    else {
        Return "x64"
    }
}

Function New-Password([int32]$length) {
    ([char[]]([char]'A'..[char]'Z') + [char[]]([char]'a'..[char]'z') + 0..9 | Sort-Object {Get-Random})[0..$length] -join ''
    #Add-Type -AssemblyName System.web
    #[System.Web.Security.Membership]::GeneratePassword($length,0)
}

Function Get-InstalledApp([string]$name) {
    Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object DisplayName -like $name | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate,UninstallString | Format-Table –AutoSize
}


#Download and install latest version on FreeSWITCH 1.6. 
#Set it to auto start
Function Install-FreeSWITCH() {
    if (Get-CPU -eq "x86") {
        $url = "http://files.freeswitch.org/windows/installer/x86/"
    }
    else {
        $url = "http://files.freeswitch.org/windows/installer/x64/"
    }
    $link = Get-Link $url "*1.6.14*"
    Write-Host Download FreeSWITCH from $link -ForegroundColor Cyan
    $filename = Get-File $link

    Write-Host "Install Freeswitch" -ForegroundColor Cyan

    #Remove FreeSWITCH
    #Start-Process  MsiExec.exe "/x {B004A325-1272-47E5-A415-A74E9FC99865} /passive /qb" -Wait
    #Install new version
    Start-Process msiexec "/i $filename /passive /qb" -Wait
    #Configure service to auto start
    Start-Process sc "config FreeSWITCH start= auto" -Wait -NoNewWindow
    #Start-Service FreeSWITCH

    #Set permissions to folder "c:\Program Files\FreeSWITCH" for PHP (IIS)
    if ($iis_identity -eq "NetworkService") {
        Icacls "c:\Program Files\FreeSWITCH" /grant "NetworkService:(OI)(CI)M"
    }
    
}

Function Install-7zip() {
    if (-not (Test-Path "c:\Program Files\7-Zip\7z.exe")) {
        Write-Host "Downloading and Installing 7-Zip" -ForegroundColor Cyan
        if ($env:PROCESSOR_ARCHITECTURE -eq "x86") {
            $zip7 = Get-File http://www.7-zip.org/a/7z1604.msi
        }
        else {
            $zip7 = Get-File http://www.7-zip.org/a/7z1604-x64.msi
        }
        Start-Process msiexec "/i $zip7 /passive /qb" -Wait
    }
}

Function Install-PostgresODBC() {
    $url = "https://ftp.postgresql.org/pub/odbc/versions/msi/"
    $link = Get-Link $url -pattern "*" + (Get-CPU) + "*"
    Write-Host Download ODBC from $link -ForegroundColor Cyan
    $filename = Get-File $link

    #Extract archive
    if ($PSVersionTable.PSVersion.Major -ge 5) {
        Expand-Archive $filename -DestinationPath .
    }
    else {
        #Check if 7zip is installed and install it if needed
        Install-7zip
        #Extract all files
        Start-Process "c:\Program Files\7-Zip\7z.exe" "e -y $filename"
    }

    Write-Host Install postgresql-odbc
    $filename = Get-Item psqlodbc*.exe
    if ($filename) {
        Start-Process $filename -Wait
    }

    $filename = Get-Item psqlodbc*.msi
    if ($filename) {
        Start-Process msiexec "/i $filename /passive /qb" -Wait
    }

    if ((Get-Command Get-OdbcDsn -ErrorAction SilentlyContinue)) {
        #Get or create DSN
        $dsn = Get-OdbcDsn FusionPBX -ErrorAction SilentlyContinue
        if ($dsn.length -eq 0) {
            # Get ODBC Driver name
            $driver = Get-OdbcDriver -Name "PostgreSQL Unicode*"
            $dsn = Add-OdbcDsn -DsnType System -Name FusionPBX -DriverName $driver
        }
	    $dsn | Set-OdbcDsn -SetPropertyValue servername=localhost
    }
    else {
        # Configure DSN with ODBC Administrator
        Write-Host The ODBC Administrator window will open. -ForegroundColor Yellow
        Write-Host Go to the System DSN tab and click *ADD* then choose PostgreSQL Unicode and click finish. -ForegroundColor Yellow
        Write-Host Use FusionPBX as name. Leave *Data Source* as is SSLmode disabled and enter the other info. -ForegroundColor Yellow
        Write-Host Press *test* to be sure the info is correct.  You should get *connection successful*. -ForegroundColor Yellow
        Write-Host Click Save then on. Go back to the script and press the any key -ForegroundColor Yellow
        #odbcconf.exe /Ld "dsn_llxatnf.txt" /A {CONFIGSYSDSN "PostgreSQL Unicode" "DSN=PostgreSQL30;DATABASE=DB;SERVER=localhost;PORT=5432|UID=teste|PWD=teste;SSLmode=disable|ReadOnl y=0|Protocol=7.4"}
        if (Get-CPU -eq "x86") { $driver="PostgreSQL Unicode" }
        else { $driver="PostgreSQL Unicode(x64)" }
        ODBCCONF.EXE /Lv dsn_log.txt CONFIGSYSDSN "$driver" "DSN=fusionpbx|server=localhost|port=5432|database=fusionpbx|Username=postgres|password=$database_password"

        Start-Process odbcad32.exe -Wait
    }

}

Function Start-PSQL([string]$command) {
    $location = Get-Location
    Set-Location "C:\Program Files\PostgreSQL\9.6\bin"
    .\psql.exe --set=PGPASSWORD=$database_password --username=postgres -c "$command" 
    Set-Location $location
}

Function Install-PostgreSQL() {
    if (Get-InstalledApp "PostgreSQL*") {
        Write-Host PostgreSQL is already installed
        return
    }
    if ($env:PROCESSOR_ARCHITECTURE -eq "x86") {
        $url = "https://get.enterprisedb.com/postgresql/postgresql-9.6.3-3-windows.exe"
    }
    else {
        $url = "https://get.enterprisedb.com/postgresql/postgresql-9.6.3-3-windows-x64.exe"
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
}

Function Install-Git(){
    if ($env:PROCESSOR_ARCHITECTURE -eq "x86") {
        $url = "https://github.com/git-for-windows/git/releases/download/v2.6.4.windows.1/Git-2.6.4-32-bit.exe"
    }
    else {
        $url = "https://github.com/git-for-windows/git/releases/download/v2.6.4.windows.1/Git-2.6.4-64-bit.exe"
    }

    Write-Host Download Git from $url -ForegroundColor Cyan
    $filename = Get-File $url
    Write-Host Install git -ForegroundColor Cyan
    Start-Process $filename /quiet -Wait
    Remove-Item $filename
}

Function Install-FusionPBX() {
    #Set directory
    if (-not (Test-Path $system_directory)) {
        New-Item $system_directory -ItemType Directory
    }

    <# #Clean default files
    if (Test-Path "$system_directory\iisstart.htm") {
        Get-ChildItem "$system_directory\*" -Recurse | Remove-Item -Force
    }
    #>
    #Clone FusionPBX GIT from Master or 4.2
    if ($system_branch -eq "stable") { $branch = "4.2" }
    else                             { $branch = ""}
    Start-Process "C:\Program Files\Git\bin\git.exe" "clone $branch https://github.com/fusionpbx/fusionpbx.git $system_directory" -Wait

    #Grant permissions to FusionPBX folder
    Icacls $system_directory /grant "${iis_identity}:(OI)(CI)M"

    #Copy configuration
    Move-Item -Path "c:\Program Files\FreeSWITCH\conf" -Destination "c:\Program Files\FreeSWITCH\conf-orig"
    Copy-Item "$system_directory\resources\templates\conf" "c:\Program Files\FreeSWITCH" -recurse

}

Function Install-IIS([string]$path,[string]$hostname,[int32]$port) {
    Add-Type -AssemblyName "Microsoft.Web.Administration"
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.Web.Administration")
    $iis = new-object Microsoft.Web.Administration.ServerManager

    #Create or set application pool
    if (-not ($iis.ApplicationPools.Item("PHP"))) {
        $pool = $iis.ApplicationPools.Add("PHP")
    }
    $pool = $iis.ApplicationPools.Item("PHP")
    $pool.ProcessModel.IdentityType = "NetworkService"
    $pool.ProcessModel.IdleTimeout = "00:30:00"

    #Grant permissions to path
    Icacls $path /grant "${iis_identity}:(OI)(CI)M"

    #Get site
    if ($port -eq 80) {
        $site = $iis.Sites[0]
        $site.Name = "FusionPBX"
    }
    elseif ($iis.sites.Item("FusionPBX")) {
        $site = $iis.Sites.Item("FusionPBX")
    }
    else {
        $site = $iis.Sites.Add("FusionPBX",$path,$port)
        Write-Host "conf/autoload_configs/xml_cdr.conf.xml should be modified" -ForegroundColor Red
    }

    $site = $iis.Sites.Item("FusionPBX")
    $site.Bindings | Format-Table protocol,EndPoint,Host,SslFlags -AutoSize

    #Set anonimous authentication to application pool identity
    $config = $iis.GetApplicationHostConfiguration()
    $auth = $config.GetSection("system.webServer/security/authentication/anonymousAuthentication", "FusionPBX/")
    $auth.SetAttributeValue("userName","")

    #Set application pool
    $app = $site.Applications | Where-Object -Property Path -eq '/'
    $app.ApplicationPoolName = $pool.Name
    
    #Set physical path
    $vd = $app.VirtualDirectories | Where-Object -Property Path -eq '/'
    $vd.PhysicalPath = $path

    #Assign host name
    if ($hostname) {
        $site.Bindings[0].Host = $hostname
    }
    #Save
    $iis.CommitChanges()
}

Function Start-WebPlatform() {
    if (-not (Test-Path "${env:ProgramFiles}\Microsoft\Web Platform Installer\WebPlatformInstaller.exe")) {
        $filename = Get-File http://download.microsoft.com/download/F/4/2/F42AB12D-C935-4E65-9D98-4E56F9ACBC8E/wpilauncher.exe
        Start-Process $filename -Wait
    }
    else {
        Start-Process "C:\Program Files\Microsoft\Web Platform Installer\WebPlatformInstaller.exe" -Wait
    }
}

Function Install-Nginx() {
	Write-Host Going to install NGINX
    $filename = Get-File http://nginx.org/download/nginx-1.12.1.zip
	. "C:\Program Files\7-Zip\7z.exe" "e $filename -oc:\Nginx"
	# needed for php7.0
	$filename = Get-File https://download.microsoft.com/download/9/3/F/93FCF1E7-E6A4-478B-96E7-D4B285925B00/vc_redist.x64.exe
	Start-Process vc_redist.x64.exe /quiet -Wait
	Write-Host Going to install PHP 7.0
	Get-File http://windows.php.net/downloads/releases/php-7.0.1-nts-Win32-VC14-x64.zip -OutFile php-7.0.1-nts-Win32-VC14-x64.zip

    $url = "http://windows.php.net/downloads/releases"
    #php-7.0.1-nts-Win32-VC14-x64.zip
    $link = Get-Link $url "*php-7.0*x64*"
    Write-Host Download PHP from $link -ForegroundColor Cyan
    $filename = Get-File $link
    Start-Process "C:\Program Files\7-Zip\7z.exe" "e $filename" -Wait

    Set-Location "C:/nginx"

}

#[System.Environment]::OSVersion.Version.Major

#Display installed applications
Get-InstalledApp "FreeSWITCH*"
Get-InstalledApp "PHP*"
Get-InstalledApp "PostgreSQL*"
#Get-InstalledApp "psqlodbc*"
Get-InstalledApp "7*"

Write-Host "This will install/update and configure FusionPBX, FreeSWITCH, PostgreSQL, PHP, 7-Zip."

# Create folder and make it current
if (-not (Test-Path "$env:PUBLIC\Downloads\FusionPBX")) {
    mkdir "$env:PUBLIC\Downloads\FusionPBX"
}
Set-Location "$env:PUBLIC\Downloads\FusionPBX"

#Required for FreeSWITCH
if ( ([System.Environment]::OSVersion.Version.Build -lt 9600) -and -not (Get-InstalledApp "FreeSWITCH*") -and -not (Get-HotFix -id KB2999226)) {
    Write-Host Install update KB2999226
    Return
}

#System Password
if ($system_password -eq 'random') {
    $system_password = New-Password 20
}
else {
    $system_password = Read-Host -Prompt "Enter system password"
}

#Database Password
if ($database_password -eq 'random') {
    $database_password = New-Password 20
}
else {
    $database_password = Read-Host -Prompt "Enter database superuser (postgres) password"
}

Install-PostgreSQL
#Install-PostgresODBC
Install-FreeSWITCH
Install-Git
Install-FusionPBX

if ($web_server -eq "IIS") {
    #Run IIS platform installer
    Write-Host "Install PHP 7.1, PHP Manager for IIS and URL Rewrite using Web Platform Installer" -ForegroundColor Yellow
    Start-WebPlatform

    #Run IIS manager and create FusionPBX app
    Write-Host "Create web site in IIS" -ForegroundColor Yellow
    Write-Host "Enable extensions php_pgsql and php_pdo_pgsql" in IIS -ForegroundColor Yellow
    Write-Host "Use URL Rewrite to import rules from .htaccess file" -ForegroundColor Yellow
    Start-Process "${env:SystemRoot}\system32\inetsrv\InetMgr.exe"

    Install-IIS -path $system_directory -port 80
    iisreset

    #Remove current configuration
    #Remove-Item c:\inetpub\FusionPBX\resources\config.php
}

#Update schema
."C:\Program Files\PHP\v7.1\php.exe" "$system_directory/core/upgrade/upgrade_schema.php"

#add the domain name

[string]$domain_uuid = [System.Guid]::NewGuid()
if ($domain_name -eq "hostname") {
    $domain_name = $env:COMPUTERNAME
}
Start-PSQL "insert into v_domains (domain_uuid, domain_name, domain_enabled) values('$domain_uuid', '$domain_name', 'true');"
."C:\Program Files\PHP\v7.1\php.exe" "$system_directory/core/upgrade/upgrade_domains.php"


#Start login page
Start-Process http://${env:COMPUTERNAME}:8090

Write-Host System:
Write-Host    Username - $system_username
Write-Host    Password - $system_password

Write-Host Database:
Write-Host    Username - postgres
Write-Host    Password - $database_password


# next part need to configure nginx.conf, php.ini(might have this pre-done and cp it from release download)
# next part create databases for postgresql
