#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

. ./config.sh
. ./colors.sh

#send a message
verbose "Installing FusionPBX"

#install dependencies
pkg install --yes git ghostscript9-base tiff

if [ .$system_branch = "master" ]; then
	verbose "Using master"
	branch=""
else
	system_version=4.2
	verbose "Using version $system_version"
	branch="-b $system_version"
fi

#get the source code
git clone $branch https://github.com/fusionpbx/fusionpbx.git /var/www/fusionpbx
chown -R www:www /var/www/fusionpbx
chmod -R 755 /var/www/fusionpbx/secure
