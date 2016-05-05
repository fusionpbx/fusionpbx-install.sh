fusionpbx-install.sh
--------------------------------------

This install script that has been designed to be an fast, simple, and modular way to to install FusionPBX. Start with a minimal install of Debian 8 with SSH enabled. Run the following commands under root. It installs FusionPBX, FreeSWITCH release package and its dependencies, IPTables, Fail2ban, NGINX, PHP FPM, and PostgresQL.

```bash
apt-get install -y git
cd /usr/src
git clone https://github.com/fusionpbx/fusionpbx-install.sh.git
chmod 755 -R /usr/src/fusionpbx-install.sh
cd /usr/src/fusionpbx-install.sh/debian
./install.sh
```

At the end of the install it will instruct you to go to the ip address of the server in your web browser to finish the install. It will also provide a random database password for you to use during the web based phase of the install. The install script builds the fusionpbx database so you will not need to use the create database username and password on the last page of the web based install.

After you have completed the install you can login with the username and password you chose during the install. After you login go to them menu then Advanced -> Upgrade select the checkbox for App defaults. Then go to Status -> SIP Status and start the SIP profiles, after this, go to Advanced -> Modules and find the module Memcached and click start.

For additional information to get started go to http://docs.fusionpbx.com/en/latest/getting_started.html 


