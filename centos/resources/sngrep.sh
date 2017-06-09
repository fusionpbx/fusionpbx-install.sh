#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

IRONTEC="[irontec]
name=Irontec RPMs repository
baseurl=http://packages.irontec.com/centos/\$releasever/\$basearch/"
echo "${IRONTEC}" > /etc/yum.repos.d/irontec.repo
rpm --import http://packages.irontec.com/public.key
yum -y install sngrep
