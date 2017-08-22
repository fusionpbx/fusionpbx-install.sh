#get the install script
Set-Location "$env:PUBLIC\Downloads"
Invoke-WebRequest https://raw.github.com/fusionpbx/fusionpbx-install.sh/master/windows/install.ps1 -OutFile install.ps1
#run the script
.\install.ps1
