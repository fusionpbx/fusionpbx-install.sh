#!/bin/sh
# Exit codes
#	1	general error
#	2	unsupported OS
#	3	unsupported CPU/OS bits

# check to confirm running as root.
if [ "$(id -u)" -ne "0" ]; then
	echo "$(basename "$0") must be run as root";
	exit 1
fi
echo

#Os/Distro Check
os_check=$(lsb_release -is)
check_major_release=$(lsb_release -rs | cut -d. -f1)

os_unsupported () {
	echo " Your Operating System appears to be: "
	lsb_release -a
	echo "Your Operating System is not currently supported... Exiting the install."
	exit 2;
}

if [ $os_check = 'Debian' ]; then
	if [ $check_major_release -ge 8 ]; then
		echo "Removing the CD image from /etc/apt/sources.list"
		sed -i '/cdrom:/d' /etc/apt/sources.list
		echo "Updating system before starting."
		apt-get update && apt-get -y upgrade
		echo "Installing Git"
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
		os_unsupported
	fi
else
	os_unsupported
fi

