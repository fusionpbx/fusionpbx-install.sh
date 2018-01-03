. .\resources\get-file.ps1
if (-not (Test-Path "c:\Program Files\7-Zip\7z.exe")) {
	$cpu = $env:PROCESSOR_ARCHITECTURE
	Write-Host "Downloading and Installing 7-Zip for $cpu" -ForegroundColor Cyan
	if ($cpu -eq "x86") {
		$zip7 = Get-File http://www.7-zip.org/a/7z1604.msi
	}
	else {
		$zip7 = Get-File http://www.7-zip.org/a/7z1604-x64.msi
	}
	Start-Process msiexec "/i $zip7 /passive /qb" -Wait
}