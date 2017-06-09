#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh
. ./environment.sh

#send a message
verbose "Installing FusionPBX"

#install dependencies
apt-get install -qq -y git dbus haveged ssl-cert
apt-get install -qq -y ghostscript libtiff5-dev libtiff-tools at

#set the version
if [ .$system_branch = .'master' ]; then
	verbose "Using master"
	branch=""
else
	system_major=$(git ls-remote --heads https://github.com/fusionpbx/fusionpbx.git | cut -d/ -f 3 | grep -P '^\d+\.\d+' | sort | tail -n 1 | cut -d. -f1)
	system_minor=$(git ls-remote --tags https://github.com/fusionpbx/fusionpbx.git $system_major.* | cut -d/ -f3 |  grep -P '^\d+\.\d+' | sort | tail -n 1 | cut -d. -f2)
	system_version=$system_major.$system_minor
	verbose "Using version $system_version"
	branch="-b $system_version"
fi

#get the source code
git clone $branch https://github.com/fusionpbx/fusionpbx.git /var/www/fusionpbx
chown -R www-data:www-data /var/www/fusionpbx
chmod -R 755 /var/www/fusionpbx/secure
