
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