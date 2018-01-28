Function Install-FusionPBX() {

	#includes
	. .\resources\new-password.ps1
	. .\resources\domain_name.ps1
	
	#Set directory
	if (-not (Test-Path $system_directory)) {
		New-Item $system_directory -ItemType Directory
	}

	# Create folder and make it current
	#if (-not (Test-Path "$env:PUBLIC\Downloads\FusionPBX")) {
	#	mkdir "$env:PUBLIC\Downloads\FusionPBX"
	#}
	#Set-Location "$env:PUBLIC\Downloads\FusionPBX"

	<# #Clean default files
	if (Test-Path "$system_directory\iisstart.htm") {
		Get-ChildItem "$system_directory\*" -Recurse | Remove-Item -Force
	}
	#>
	#Clone FusionPBX GIT from Master or 4.2
	if ($system_branch -eq "stable") { $branch = "4.2" }
	else                             { $branch = ""}
	Start-Process "C:\Program Files\Git\bin\git.exe" "clone $branch https://github.com/fusionpbx/fusionpbx.git C:/inetpub/FusionPBX/" -Wait

	#Grant permissions to FusionPBX folder
	if ($iis_identity -ne "LocalSystem") {
		Icacls $system_directory /grant "${iis_identity}:(OI)(CI)M"
	}

	#Copy configuration
	Move-Item "c:\Program Files\FreeSWITCH\conf" "c:\Program Files\FreeSWITCH\conf-orig"
	Copy-Item "c:\inetpub\FusionPBX\resources\templates\conf" "c:\Program Files\FreeSWITCH\" -recurse

	#Update xml_cdr url, user and password
	$filename = "C:\Program Files\FreeSWITCH\conf\autoload_configs\xml_cdr.conf.xml"
	(Get-Content $filename) -replace "{v_http_protocol}","http" `
				-replace "{domain_name}",$domain_name `
				-replace "{v_project_path}","" `
				-replace "{v_user}:{v_pass}",((New-Password 8) + ":" + (New-Password 8)) | Out-File $filename

}
