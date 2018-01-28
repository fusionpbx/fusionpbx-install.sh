Function Install-Git(){

	if (Get-Installed-App "Git*") {
		Write-Host "Git is already installed"
		return
	}

	#install Git for Windows
	if ($env:PROCESSOR_ARCHITECTURE -eq "x86") {
		$url = "https://github.com/git-for-windows/git/releases/download/v2.15.1.windows.2/Git-2.15.1.2-32-bit.exe"
	}
	else {
		$url = "https://github.com/git-for-windows/git/releases/download/v2.15.1.windows.2/Git-2.15.1.2-64-bit.exe"
	}

	Write-Host Download Git from $url -ForegroundColor Cyan
	$filename = Get-File $url
	Write-Host Install git -ForegroundColor Cyan
	Start-Process $filename /silent -Wait
	Remove-Item $filename

	#install TortoiseGit
	if ($env:PROCESSOR_ARCHITECTURE -eq "x86") {
		$url = "https://download.tortoisegit.org/tgit/2.5.0.0/TortoiseGit-2.5.0.0-32bit.msi"
	}
	else {
		$url = "https://download.tortoisegit.org/tgit/2.5.0.0/TortoiseGit-2.5.0.0-64bit.msi"
	}
	$filename = Get-File $url
	Start-Process $filename /passive -Wait

}