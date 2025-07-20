#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ../config.sh
. ../colors.sh
. ../environment.sh

apt-get update && apt-get install -y curl memcached haveged apt-transport-https
apt-get update && apt-get install -y gnupg gnupg2
apt-get update && apt-get install -y wget lsb-release

if [ ."$cpu_architecture" = ."x86" ] || [ ."$cpu_architecture" = ."arm" ]; then
	wget --http-user=signalwire --http-password=$switch_token -O /usr/share/keyrings/signalwire-freeswitch-repo.gpg https://freeswitch.signalwire.com/repo/deb/debian-release/signalwire-freeswitch-repo.gpg
	echo "machine freeswitch.signalwire.com login signalwire password $switch_token" > /etc/apt/auth.conf
	echo "deb [signed-by=/usr/share/keyrings/signalwire-freeswitch-repo.gpg] https://freeswitch.signalwire.com/repo/deb/debian-release/ `lsb_release -sc` main" > /etc/apt/sources.list.d/freeswitch.list
	echo "deb-src [signed-by=/usr/share/keyrings/signalwire-freeswitch-repo.gpg] https://freeswitch.signalwire.com/repo/deb/debian-release/ `lsb_release -sc` main" >> /etc/apt/sources.list.d/freeswitch.list
fi
