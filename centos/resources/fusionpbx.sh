#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

. ./colors.sh
. ./arguments.sh

verbose "Installing FusionPBX"

yum -y install git
yum -y install ghostscript libtiff-devel libtiff-tools

IRONTEC="[irontec]
name=Irontec RPMs repository
baseurl=http://packages.irontec.com/centos/$releasever/$basearch/"
echo "${IRONTEC}" > /etc/yum.repos.d/irontec.repo
rpm --import http://packages.irontec.com/public.key
yum -y install sngrep

wget https://forensics.cert.org/cert-forensics-tools-release-el7.rpm
rpm -Uvh cert-forensics-tools-release*rpm
yum -y --enablerepo=forensics install lame

if [ $USE_SYSTEM_MASTER = true ]; then
	verbose "Using master"
	BRANCH=""
else
	FUSION_MAJOR=$(git ls-remote --heads https://github.com/fusionpbx/fusionpbx.git | cut -d/ -f 3 | grep -P '^\d+\.\d+' | sort | tail -n 1 | cut -d. -f1)
	FUSION_MINOR=$(git ls-remote --tags https://github.com/fusionpbx/fusionpbx.git $FUSION_MAJOR.* | cut -d/ -f3 |  grep -P '^\d+\.\d+' | sort | tail -n 1 | cut -d. -f2)
	FUSION_VERSION=$FUSION_MAJOR.$FUSION_MINOR
	verbose "Using version $FUSION_VERSION"
	BRANCH="-b $FUSION_VERSION"
fi

#get the source code
git clone $BRANCH https://github.com/fusionpbx/fusionpbx.git /var/www/fusionpbx

verbose "FusionPBX Installed"