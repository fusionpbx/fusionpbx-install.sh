#!/bin/bash
#This script will reboot all the phones in a particular domain for a specified model. A pause is optional.

#gather parameters 
read -p "Enter the Domain to Reboot (example: abc.net):" domain
read -p "Enter the phone type to reboot (polycom, yealink, cisco):" vendor
read -p "Enter the time in seconds to pause between phones:" pausetime

#create a temp file
NOW=$(date +"%Y%m%d_%H%M%S")
FILE="registrations-$NOW.csv"

#gather the registrations from freeswitch
eval 'fs_cli -x "show registrations" > $FILE'

#create some variables
N=0
ARR=()

#set the internal field separator
IFS=","
INPUT=$FILE

#Loop through the registrations and reboot
[ ! -f $INPUT ] &while read reg_user realm extra
do
        if [ ."$realm" = ."$domain" ]; then
                eval 'fs_cli -x "luarun app.lua event_notify internal reboot $reg_user@$realm $vendor"'
		if [ "$pausetime" > 0 ]; then
			sleep $pausetime
        	fi
	fi
done < $INPUT
IFS=$OLDIFS

#remove the file
rm $FILE
