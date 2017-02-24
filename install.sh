#!/bin/sh
# Exit codes
#	1	general error
#	2	unsupported OS
#	3	unsupported CPU/OS bits

verbose () {
	echo "${green}$1${normal}"
}
error	() {
	echo "${red}$1${normal}"
}

# check for color support
if test -t 1; then

    # see if it supports colors...
    ncolors=$(tput colors)

    if test -n "$ncolors" && test $ncolors -ge 8; then
        bold="$(tput bold)"
        underline="$(tput smul)"
        standout="$(tput smso)"
        normal="$(tput sgr0)"
        black="$(tput setaf 0)"
        red="$(tput setaf 1)"
        green="$(tput setaf 2)"
        yellow="$(tput setaf 3)"
        blue="$(tput setaf 4)"
        magenta="$(tput setaf 5)"
        cyan="$(tput setaf 6)"
        white="$(tput setaf 7)"
    fi
	verbose "Enabled color support"
fi

# check to confirm running as root.
if [ "$(id -u)" -ne "0" ]; then
	error "$(basename "$0") must be run as root";
	exit 1
fi

#Make ourselves executable next time we are run
chmod +x $0

#Os/Distro Check
os_check=$(lsb_release -is)
real_os=$os_check
check_major_release=$(lsb_release -rs | cut -d. -f1)
check_codename=$(lsb_release -cs)

os_unsupported () {
	echo " Your Operating System appears to be: "
	lsb_release -a
	error "Your Operating System is not currently supported... Exiting the install."
	exit 2;
}

os_debian_common () {
	verbose "Removing the CD image from /etc/apt/sources.list"
	sed -i '/cdrom:/d' /etc/apt/sources.list
	verbose "Updating system before starting."
	apt-get update && apt-get -y upgrade
	verbose "Installing Git"
	apt-get install -y git
}
os_fetch_installer () {
	if [ ! -d /usr/src ]; then
		mkdir -vp /usr/src
	fi
	cd /usr/src
	verbose "Fetching Installer"
	if [ -d /usr/src/fusionpbx-install.sh ]; then
		cd /usr/src/fusionpbx-install.sh
		git pull
	else
		git clone https://github.com/fusionpbx/fusionpbx-install.sh
	fi
}

if [ .$os_check = .'Raspbian' ]; then
	echo "${yellow}Detected Raspbian, using Debian for compatibility${normal}"
	os_check="Debian"
fi
if [ .$os_check = .'Ubuntu' ]; then
	echo "${yellow}Detected Ubuntu, using Debian for compatibility${normal}"
	os_check="Debian"
fi
if [ .$os_check = .'Debian' ]; then
	if [ .$real_os = .'Debian' ]; then
		echo "${yellow}Detected Debian${normal}"
		if [ $check_major_release -ge 8 ]; then
			os_debian_continue='true'
		else
			os_debian_continue='false'
			error "Although you are running $real_os we require version >= 8"
			os_unsupported
		fi
	fi
	if [ .$real_os = .'Ubuntu' ]; then
		if [ $check_major_release -ge 14 ]; then
			os_debian_continue='true'
		else
			os_debian_continue='false'
			error "Although you are running $real_os we require version >= 14"
			os_unsupported
		fi
	fi
	if [ .$os_debian_continue = .'true' ]; then
		os_debian_common
		os_fetch_installer
		cd /usr/src/fusionpbx-install.sh/debian
		./install.sh $@
	fi
else
	os_unsupported
fi
