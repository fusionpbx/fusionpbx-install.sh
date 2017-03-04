

if [ .$USE_SWITCH_SOURCE = .true ]; then
	if [ .$USE_SWITCH_MASTER = .true ]; then
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

else
	if [ .$USE_SWITCH_MASTER = .true ]; then
		if [ .$USE_SWITCH_PACKAGE_ALL = .true ]; then
			resources/switch/package-master-all.sh
		else
			resources/switch/package-master.sh
		fi
	else
		if [ .$USE_SWITCH_PACKAGE_ALL = .true ]; then
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
