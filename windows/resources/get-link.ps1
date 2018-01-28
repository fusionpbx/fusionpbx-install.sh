
# Get page with links, filter, and select latest version using pattern. Return file download URL.
Function Get-Link([string]$url, [string]$pattern) {
	$link = (Invoke-WebRequest $url).Links | Where-Object {$_.href -like $pattern} | Select-Object -Last 1
	Write-Host $link.href -ForegroundColor Gray

	#Use System.URI to combine url parts
	$uri = New-Object -TypeName System.URI -ArgumentList ([System.URI]$url),($link.href)
	return $uri.AbsoluteUri
}