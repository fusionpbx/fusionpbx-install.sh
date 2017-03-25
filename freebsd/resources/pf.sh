#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

. ./config.sh
. ./colors.sh

#send a message
verbose "Configuring IPTables"

#run iptables commands

