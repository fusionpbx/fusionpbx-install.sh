
FusionPBX Install
--------------------------------------
A quick install guide & scripts for installing FusionPBX. It is recommended to start with a minimal install of the operating system. Notes on further tweaking your configuration are at end of the file.

## Operating Systems

### Debian and Raspberry OS
Debian is the preferred operating system by the FreeSWITCH developers. It supports the latest video dependencies and should be used if you want to do video mixing. Download Debian at https://cdimage.debian.org/cdimage/release/current/

```sh
wget -O - https://raw.githubusercontent.com/fusionpbx/fusionpbx-install.sh/master/debian/pre-install.sh | sh;
cd /usr/src/fusionpbx-install.sh/debian && ./install.sh
```

### Ubuntu and Raspberry OS
```sh
wget -O - https://raw.githubusercontent.com/fusionpbx/fusionpbx-install.sh/master/ubuntu/pre-install.sh | sh;
cd /usr/src/fusionpbx-install.sh/ubuntu && ./install.sh
```

### Devuan
If you like Debian but rather not bother with systemd, Devuan is a "drop in" replacement.
Devuan ASCII is based on Stretch, so you will find most of the same packages available.
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

## Security Considerations
Fail2ban is installed and pre-configured for all operating systems this repository works on besides Windows, but the default settings may not be ideal depending on your needs. Please take a look at the jail file (/etc/fail2ban/jail.local on Debian/Devuan) to configure it to suit your application and security model!

## ISSUES
If you find a bug sign up for an account on www.fusionpbx.com to report the issue.
