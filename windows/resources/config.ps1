
# FusionPBX Settings
$domain_name = "hostname"            # hostname, ip_address or a custom value
$system_username = "admin"           # default username admin
$system_password = "random"          # random or a custom value
$system_branch = "master"            # master, stable
$system_directory = "${env:SystemDrive}\inetpub\FusionPBX"

# FreeSWITCH Settings
$switch_version = "1.6"              # *1.6.*

# Database Settings
$database_password = "random"        # random or a custom value

# General Settings
$php_version = 7                     # PHP version 7
$web_server = "IIS"                  # nginx or IIS
$iis_identity = "LocalSystem"        # localSystem or NetworkService
