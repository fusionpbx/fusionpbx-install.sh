#Download and install latest version on FreeSWITCH 1.6. 
#Set it to auto start
Function Install-FreeSWITCH() {
	. .\resources\get-link.ps1
	. .\resources\get-file.ps1
    . .\resources\get-cpu.ps1

	if (Get-Installed-App "FreeSWITCH*") {
		Write-Host FreeSWITCH is already installed
		return
	}

	$cpu = Get-CPU
	if ($cpu -eq "x86") {
		$url = "http://files.freeswitch.org/windows/installer/x86/"
	}
	else {
		$url = "http://files.freeswitch.org/windows/installer/x64/"
	}
	$link = Get-Link $url "*${switch_version}*"
	Write-Host Download FreeSWITCH from $link -ForegroundColor Cyan
	$filename = Get-File $link

	#Required for FreeSWITCH
	if ( ([System.Environment]::OSVersion.Version.Build -lt 9600) -and -not (Get-Installed-App "FreeSWITCH*") -and -not (Get-HotFix -id KB2999226)) {
		Write-Host Install update KB2999226
		Return
	}

	Write-Host "Install Freeswitch" -ForegroundColor Cyan

	#Remove FreeSWITCH
	Start-Process  MsiExec.exe "/x {B004A325-1272-47E5-A415-A74E9FC99865} /passive /qb" -Wait
	#Install new version
	Start-Process msiexec "/i $filename /passive /qb" -Wait
	#Configure service to auto start
	Start-Process sc "config FreeSWITCH start= auto" -Wait -NoNewWindow
	#Start-Service FreeSWITCH

	#Set permissions to folder "c:\Program Files\FreeSWITCH" for PHP (IIS)
	if ($iis_identity -ne "LocalSystem") {
		Icacls "c:\Program Files\FreeSWITCH" /grant "NetworkService:(OI)(CI)M"
	}

	#mod_lua.dll is missing from recent windows builds
	$lua = "C:\Program Files\FreeSWITCH\mod\mod_lua.dll"
	if ( -not (Test-Path $lua) )  {
		Get-File "https://github.com/fusionpbx/fusionpbx-install.sh/raw/master/windows/resources/$cpu/mod_lua.dll"
		Copy-Item ".\mod_lua.dll" -Destination $lua
	}    
}
