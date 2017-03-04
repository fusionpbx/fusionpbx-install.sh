#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh

if [ .$switch_source = .true ]; then
	if [ ."$switch_branch" = "master" ]; then
		resources/switch/source-master.sh
	else
		resources/switch/source-release.sh
	fi

	#copy the switch conf files to /etc/freeswitch
	resources/switch/conf-copy.sh

	#set the file permissions
	resources/switch/source-permissions.sh

	#systemd service
	resources/switch/source-systemd.sh
fi

if [ .$switch_package = .true ]; then
	if [ ."$switch_branch" = "master" ]; then
		if [ .$switch_package_all = .true ]; then
			resources/switch/package-master-all.sh
		else
			resources/switch/package-master.sh
		fi
	else
		if [ .$switch_package_all = .true ]; then
			resources/switch/package-all.sh
		else
			resources/switch/package-release.sh
		fi
	fi

	#copy the switch conf files to /etc/freeswitch
	resources/switch/conf-copy.sh

	#set the file permissions
	resources/switch/package-permissions.sh

	#systemd service
	resources/switch/package-systemd.sh
fi
