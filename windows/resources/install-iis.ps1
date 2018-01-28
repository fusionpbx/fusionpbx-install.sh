Install-WindowsFeature -name Web-Server -IncludeManagementTools
Install-WindowsFeature Web-Mgmt-Console
Install-WindowsFeature Web-Mgmt-Service
Install-WindowsFeature Web-Http-Redirect
Function Install-IIS([string]$path) {

	#Run IIS manager and create FusionPBX app
	Write-Host "Create web site in IIS" -ForegroundColor Yellow
	Write-Host "Enable extensions php_pgsql and php_pdo_pgsql" in IIS -ForegroundColor Yellow
	Write-Host "Use URL Rewrite to import rules from .htaccess file" -ForegroundColor Yellow
	Start-Process "${env:SystemRoot}\system32\inetsrv\InetMgr.exe"
    
    

	#Install-IIS -path $system_directory -port 80
	invoke-command -scriptblock {iisreset}

	#Remove current configuration
	#Remove-Item c:\inetpub\FusionPBX\resources\config.php

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
	if ($iis_identity -ne "LocalSystem") {
		Icacls $path /grant "${iis_identity}:(OI)(CI)M"
	}

	$site= $iis.Sites | Where-Object Bindings -Like "*:80:*"
	#Get site
	if ($site) {
		$site.Name = "FusionPBX"
	}
	elseif ($iis.sites.Item("FusionPBX")) {
		$site = $iis.Sites.Item("FusionPBX")
	}
	else {
		$site = $iis.Sites.Add("FusionPBX",$path,80)
	}

	#$site.Bindings | Format-Table protocol,EndPoint,Host,SslFlags -AutoSize

	#$cert = (Get-ChildItem ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Å“Path cert:\LocalMachine\My | Sort-Object NotAfter | Select-Object -Last 1).Thumbprint
	#netsh http delete sslcert ipport=0.0.0.0:443
	#netsh http add sslcert ipport=0.0.0.0:443 certhash=$cert "appid={4dc3e181-e14b-4a21-b022-59fc669b0914}"
	#netsh http show sslcert

	#Set anonymous authentication to application pool identity
	$config = $iis.GetApplicationHostConfiguration()
	$auth = $config.GetSection("system.webServer/security/authentication/anonymousAuthentication", "FusionPBX/")
	$auth.SetAttributeValue("userName","")

	#Set application pool
	$app = $site.Applications | Where-Object -Property Path -eq '/'
	$app.ApplicationPoolName = $pool.Name

	#Set physical path
	$vd = $app.VirtualDirectories | Where-Object -Property Path -eq '/'
	$vd.PhysicalPath = $path

	#Save
	$iis.CommitChanges()

    #Add pgsql extensions to php.ini
    Add-Content "c:\Program Files\PHP\v7.1\php.ini" "`nextension=php_pgsql.dll"
    Add-Content "c:\Program Files\PHP\v7.1\php.ini" "`nextension=php_pdo_pgsql.dll"
    invoke-command -scriptblock {iisreset}

}
