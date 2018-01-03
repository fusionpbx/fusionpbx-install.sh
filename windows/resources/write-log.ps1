Function Write-Log([string]$message) {
	Add-Content -Path "install.log" -Value $message
	Write-Host $message -ForegroundColor Cyan
}