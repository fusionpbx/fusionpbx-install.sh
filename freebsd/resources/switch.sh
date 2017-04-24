#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh

#install the package
if [ .$switch_source = "package" ]; then
	#run the package install
	switch/package-release.sh

	#copy the switch conf files
	switch/package-conf-copy.sh

	#set the file permissions
	switch/package-permissions.sh
fi

#install from source
if [ .$switch_source = "source" ]; then
	#compile the source
	if [ ."$switch_branch" = "master" ]; then
		switch/source-master.sh
	else
		switch/source-release.sh
	fi

	#copy the switch conf files
	switch/source-conf-copy.sh

	#set the file permissions
	switch/source-permissions.sh
fi
