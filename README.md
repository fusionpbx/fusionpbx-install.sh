
FusionPBX Install
--------------------------------------
A quick install guide for a FusionPBX install. It is recommended to start the install on a minimal install.


### Debian
Debian is the preferred operating system by the FreeSWITCH developers. 
It supports the latest video dependencies. If you want to do video mixing use Debian.

```sh
wget -O - https://raw.githubusercontent.com/fusionpbx/fusionpbx-install.sh/master/pre-install.sh | sh
cd /usr/src/fusionpbx-install.sh/debian && ./install.sh
```

### CentOS
This is the operating system is a requirement for some companies. This install may new and may need additional work.

```sh
wget -O - https://raw.githubusercontent.com/fusionpbx/fusionpbx-install.sh/master/pre-install.sh | sh
cd /usr/src/fusionpbx-install.sh/centos && ./install.sh
```
