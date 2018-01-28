#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh

#send a message
verbose "Installing FusionPBX"

#install dependencies
pkg install --yes git ghostscript9-base tiff

#set the version
if [ .$system_branch = .'master' ]; then
	verbose "Using master"
	branch=""
else
	system_version=4.2
	verbose "Using version $system_version"
	branch="-b $system_version"
fi

#get the source code
git clone $branch https://github.com/fusionpbx/fusionpbx.git /usr/local/www/fusionpbx
chown -R www:www /usr/local/www/fusionpbx
chmod -R 755 /usr/local/www/fusionpbx/secure
