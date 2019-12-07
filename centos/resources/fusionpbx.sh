#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh

#send a message
verbose "Installing FusionPBX"

#install dependencies
yum -y install git
yum -y install ghostscript libtiff-devel libtiff-tools at

#forensics tools
wget https://forensics.cert.org/cert-forensics-tools-release-el7.rpm
rpm -Uvh cert-forensics-tools-release*rpm
yum -y --enablerepo=forensics install lame

#get the branch
if [ .$system_branch = .'master' ]; then
	verbose "Using master"
	BRANCH=""
else
	FUSION_MAJOR=$(git ls-remote --heads https://github.com/fusionpbx/fusionpbx.git | cut -d/ -f 3 | grep -P '^\d+\.\d+' | sort | tail -n 1 | cut -d. -f1)
	FUSION_MINOR=$(git ls-remote --tags https://github.com/fusionpbx/fusionpbx.git $FUSION_MAJOR.* | cut -d/ -f3 |  grep -P '^\d+\.\d+' | sort | tail -n 1 | cut -d. -f2)
	FUSION_VERSION=$FUSION_MAJOR.$FUSION_MINOR
	verbose "Using version $FUSION_VERSION"
	BRANCH="-b $FUSION_VERSION"
fi

#add the cache directory
mkdir -p /var/cache/fusionpbx
chown -R freeswitch:daemon /var/cache/fusionpbx

#get the source code
git clone $BRANCH https://github.com/fusionpbx/fusionpbx.git /var/www/fusionpbx
chmod -R 744 /var/www/fusionpbx
chmod -R 755 /var/www/fusionpbx/secure

#send a message
verbose "FusionPBX Installed"
