#!/bin/sh
# check to confirm running as root.
if [ "$(id -u)" -ne "0" ]; then
	echo "$(basename "$0") must be run as root";
	exit 1
fi
echo

#Os/Distro Check
check_OS=$(lsb_release -is)
check_Release_Major=$(lsb_release -rs | cut -d. -f1)
lsb_release -c | grep -i jessie > /dev/null

function unsupported_OS {
		echo " Your OS appears to be: "
		lsb_release -a
		echo " Your OS is not currently supported... Exiting the install."
		echo "If you require assistance we are available via IRC on freenode via #fusionpbx"
		exit 2;
}

if [ $check_OS = 'Debian' ]; then
	if [ $check_Release_Major -ge 8 ]; then
		echo "Removing the cd img from /etc/apt/sources.list"
		sed -i '/cdrom:/d' /etc/apt/sources.list
		echo "Updating system before we start"
		apt-get update && apt-get -y upgrade
		echo "Installing git"
		apt-get install -y git
		cd /usr/src
		echo "Fetching Installer"
		if [ -d /usr/src/fusionpbx-install.sh ]; then
			echo "Cannot continue you already have a installer downloaded"
			exit 1
		fi
		git clone https://github.com/fusionpbx/fusionpbx-install.sh
		cd /usr/src/fusionpbx-install.sh/debian
		./install.sh $@
	else
		echo "Although you are running Debian we require version >= 8"
		unsupported_OS
	fi
else
	unsupported_OS
fi
echo "If you require assistance we are available via IRC on freenode via #fusionpbx"