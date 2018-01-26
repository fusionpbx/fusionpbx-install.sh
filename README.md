
FusionPBX Install
--------------------------------------
A quick install guide for a FusionPBX install. It is recommended to start the install on a minimal install of the operating system.


### Debian
Debian 8 is the preferred operating system by the FreeSWITCH developers. It supports the latest video dependencies. If you want to do video mixing use Debian. Download Debian 8 Jessie from here https://cdimage.debian.org/cdimage/archive/

```sh
wget -O - https://raw.githubusercontent.com/fusionpbx/fusionpbx-install.sh/master/debian/pre-install.sh | sh;
cd /usr/src/fusionpbx-install.sh/debian && ./install.sh
```
### Devuan
If you like Debian but rather not bother with systemd, Devuan is a "drop in" replacement.
Version 1 is bassed on Jessie. So you will find the same packages available.
Please note that the source installation and installation on ARM is not fully tested.

```sh
wget -O - https://raw.githubusercontent.com/fusionpbx/fusionpbx-install.sh/master/devuan/pre-install.sh | sh;
cd /usr/src/fusionpbx-install.sh/devuan && ./install.sh
```

### FreeBSD
FreeBSD is an operating system that has many great features like ZFS, HAST, CARP and more.

```sh
pkg install --yes git
cd /usr/src && git clone https://github.com/fusionpbx/fusionpbx-install.sh.git
cd /usr/src/fusionpbx-install.sh/freebsd/
./install.sh
```

### CentOS
CentOS operating system is a requirement for some companies. Don't expect video mixing to work. It will likely be a year or more for video mixing dependencies to be updated enough to work in CentOS.

```sh
wget -O - https://raw.githubusercontent.com/fusionpbx/fusionpbx-install.sh/master/centos/pre-install.sh | sh
cd /usr/src/fusionpbx-install.sh/centos && ./install.sh
```

### Windows
*  This powershell install for windows is currently in a "beta stage".
*  mod_lua is missing from builds after 1.6.14. Script will download it from github.
*  Click to download the zip file and extract it.
*  Extract the zip file
*  Navigate to install.ps1
*  Click on install.ps1 then right click on install.ps1 then choose Run with Powershell 
*  If you are not already Administrator you will have to choose run as Administrator

```sh

Master https://github.com/fusionpbx/fusionpbx-install.sh/archive/master.zip
```
