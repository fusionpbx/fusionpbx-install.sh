#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ../config.sh
. ../environment.sh

# change the working directory
if [ ."$switch_branch" = ."master" ]; then
    cd /usr/src/freeswitch
else
    cd /usr/src/freeswitch-$switch_version
fi

# compile and install the sounds
make sounds-install moh-install
make hd-sounds-install hd-moh-install
make cd-sounds-install cd-moh-install

#move the music into music/default directory
mkdir -p /usr/share/freeswitch/sounds/music/default
mv /usr/share/freeswitch/sounds/music/*000 /usr/share/freeswitch/sounds/music/default
