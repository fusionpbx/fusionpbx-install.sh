
# FusionPBX Settings
domain_name=ip_address                      # hostname, ip_address or a custom value
system_username=admin                       # default username admin
system_password=random                      # random or a custom value
system_branch=master                        # master, stable

# FreeSWITCH Settings
switch_branch=stable                        # master, stable
switch_source=false                         # true (source compile) or false (binary package)
switch_package=true                         # true (binary package) or false (source compile)
switch_version=1.10.7                       # which source code to download, only for source
switch_tls=true                             # true or false
switch_token=                               # Get the auth token from https://signalwire.com
                                            # Signup or Login -> Profile -> Personal Auth Token
# Database Settings
database_password=random                    # random or a custom value (safe characters A-Z, a-z, 0-9)
database_repo=system                        # PostgreSQL official, system, 2ndquadrant
database_version=latest                     # requires repo official
database_host=127.0.0.1                     # hostname or IP address
database_port=5432                          # port number
database_backup=false                       # true or false

# General Settings
php_version=7.4                             # PHP version 7.3, 7.4
letsencrypt_folder=false                    # true or false
