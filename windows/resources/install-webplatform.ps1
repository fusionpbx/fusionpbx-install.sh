Function Install-WebPlatform() {
	#includes
	. .\resources\get-file.ps1
    . .\resources\get-cpu.ps1

	#send message
	if (Get-Installed-App "*Web Platform*") {
		Write-Host "Web Platform Installer is already installed"
		return
	}

	#download and install the web platform installer
    if (-not (Test-Path "${env:ProgramFiles}\Microsoft\Web Platform Installer\WebPlatformInstaller.exe")) {
        $url = "http://download.microsoft.com/download/F/4/2/F42AB12D-C935-4E65-9D98-4E56F9ACBC8E/wpilauncher.exe"
        $filename = Get-File $url
        Start-Process $filename -Wait
    }
    else {
		Start-Process "C:\Program Files\Microsoft\Web Platform Installer\WebPlatformInstaller.exe" -Wait
	}

	# list available applications - All, Available
	# WebpiCmd-x64.exe /list /listoption:Available

    # install PHP 7.1 on IIS
    if (-not (Test-Path "${env:ProgramFiles}\PHP\v7.1\php.exe")) {
	    $cpu = Get-CPU
	    if ($cpu -eq "x86") {
	        $command = "WebpiCmd.exe /install /Products:PHP71 /AcceptEula"
        }
        else {
	        $command = "WebpiCmd-x64.exe /install /Products:PHP71x64 /AcceptEula"
        }
        Start-Process $command -Wait
    }

}