
# FusionPBX Settings
domain_name=ip_address          # hostname, ip_address or a custom value
system_username=admin           # default username admin
system_password=random          # random or a custom value
system_branch=5.2               # master, 5.2

# FreeSWITCH Settings
switch_branch=stable            # master, stable
switch_source=true              # true or false
switch_package=false            # true or false
switch_version=1.10.11           # only for source
switch_tls=true                 # true or false

# Sofia-Sip Settings
sofia_version=1.13.17            # release-version for sofia-sip to use

# Database Settings
database_name=fusionpbx         # Database name (safe characters A-Z, a-z, 0-9)
database_username=fusionpbx     # Database username (safe characters A-Z, a-z, 0-9)
database_password=random        # random or a custom value (safe characters A-Z, a-z, 0-9)
database_repo=system            # PostgreSQL official, system, 2ndquadrant
database_version=13             # requires repo official
database_host=127.0.0.1         # hostname or IP address
database_port=5432              # port number
database_backup=false           # true or false

# General Settings
php_version=8.1                 # PHP version 5.6 or 7.0, 7.1, 7.2, 8.1
letsencrypt_folder=true         # true or false
