
# FusionPBX Settings
domain_name=ip_address          # hostname, ip_address or a custom value
system_username=admin           # default username admin
system_password=random          # random or as a pre-set value
system_branch=stable            # master, stable

# FreeSWITCH Settings
switch_enabled=true             # true or false
switch_branch=stable            # master, stable (master requires source)
switch_source=source            # package, port, source

# Database Settings
database_enabled=true           # true or false
database_password=random        # random or as a pre-set value
database_version=9.6            # Postgres 9.3, 9.6
database_host=127.0.0.1         # hostname or IP address
database_port=5432              # port number
database_backup=false           # true or false

# Firewall Settings
firewall_enabled=true           # true or false

# General Settings
interface_name=auto             # auto, em0, igb0, vtnet0, or other valid names
php_version=7                   # PHP version 7
portsnap_enabled=false          # true or false
sngrep_enabled=true             # true or false
fail2ban_enabled=true           # true or false
nginx_enabled=true              # true or false
monit_enabled=true              # true or false
