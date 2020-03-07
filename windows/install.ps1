# Install FusionPBX
#   Installs PostreSQL, PostgreSQL ODBC driver, PHP 7.1, GIT, Web Platform Installer,
#   Configures ODBC, IIS, and FusionPBX

# "Uncomment and remove this comment to enable weak security ciphers" [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls, ssl3"

# includes
. .\resources\config.ps1
. .\resources\get-file.ps1
. .\resources\get-link.ps1
. .\resources\get-installed-app.ps1
. .\resources\install-postgresql.ps1
. .\resources\install-postgresql-odbc.ps1
. .\resources\install-freeswitch.ps1
. .\resources\install-git.ps1
. .\resources\install-fusionpbx.ps1
. .\resources\install-webplatform.ps1
. .\resources\install-iis.ps1

# installed applications
Get-Installed-App "FreeSWITCH*"
Get-Installed-App "PHP*"
Get-Installed-App "PostgreSQL*"
Get-Installed-App "psqlODBC*"
Get-Installed-App "7zip"

Install-PostgreSQL
Install-PostgresODBC
Install-FreeSWITCH
Install-Git
Install-FusionPBX
Install-WebPlatform
Install-IIS

# Finish the install
. .\resources\finish.ps1
