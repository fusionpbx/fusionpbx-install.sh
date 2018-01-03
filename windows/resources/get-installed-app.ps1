Function Get-Installed-App([string]$name) {
	Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object DisplayName -like $name | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate,UninstallString | Format-Table -AutoSize
}