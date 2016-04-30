# fusionpbx-install.sh

Debian 8

This install script that has been designed to be a fast, simple, modular and easy way to to install FusionPBX. Run this script under root. The script is to the point it begins immediatly. It installs FusionPBX, FreeSWITCH release package and its dependencies, IPTables, Fail2ban, NGINX, PHP FPM, and PostgresQL.

```bash
apt-get install -y git
git clone https://github.com/fusionpbx/fusionpbx-install.sh.git
chmod 755 -R /usr/src/fusionpbx-install.sh
cd /usr/src/fusionpbx-install.sh/debian
./install.sh
```
