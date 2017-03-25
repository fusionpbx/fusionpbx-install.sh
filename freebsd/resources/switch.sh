#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh

if [ .$switch_source = .true ]; then
	if [ ."$switch_branch" = "master" ]; then
		switch/source-master.sh
	else
		switch/source-release.sh
	fi

	#copy the switch conf files to /etc/freeswitch
	switch/conf-copy.sh

	#set the file permissions
	switch/source-permissions.sh

	#systemd service
	switch/source-systemd.sh
fi

if [ .$switch_package = .true ]; then
	if [ ."$switch_branch" = "master" ]; then

	else

	fi
fi
