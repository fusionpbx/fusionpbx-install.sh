Function Expand-ZIP([string]$filename) {
	#Extract archive
	if ($PSVersionTable.PSVersion.Major -ge 5) {
		Expand-Archive $filename -DestinationPath .
	}
	elseif ( [System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") ) {
		$path = Get-Location
		[System.IO.Compression.ZipFile]::ExtractToDirectory("$path\$filename",$path)
	}
	else {
		#Check if 7zip is installed and install it if needed
		. .\resources\install-7zip.ps1
		Install-7zip
		#Extract all files
		Start-Process "c:\Program Files\7-Zip\7z.exe" "e -y $filename"
	}
}