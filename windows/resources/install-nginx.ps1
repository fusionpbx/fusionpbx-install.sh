Function Install-Nginx() {
	. .\resources\get-file.ps1
	. .\resources\get-link.ps1
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