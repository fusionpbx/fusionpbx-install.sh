#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh

#install the package
if [ .$switch_source = ."package" ]; then
	#run the package install
	switch/package-release.sh

	#copy the switch conf files
	switch/package-copy.sh

	#set the file permissions
	switch/package-permissions.sh
fi

#install from source
if [ .$switch_source = ."source" ]; then
	#compile the source
	if [ ."$switch_branch" = "master" ]; then
		switch/source-master.sh
	else
		switch/source-release.sh
	fi

	#copy the switch conf files
	switch/source-copy.sh

	#set the file permissions
	switch/source-permissions.sh
fi

#restart the service
service freeswitch restart

#waiting to start
echo "Allow time for FreeSWITCH to start";
for i in `seq 1 3`; do
	echo $i
	sleep 1
done

