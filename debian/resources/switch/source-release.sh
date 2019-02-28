#!/bin/sh

# add repo key
wget -O - https://files.freeswitch.org/repo/deb/freeswitch-1.8/fsstretch-archive-keyring.asc | apt-key add -

# add repo
echo "deb  http://files.freeswitch.org/repo/deb/freeswitch-1.8/  stretch main" > /etc/apt/sources.list.d/freeswitch.list
echo "deb-src  http://files.freeswitch.org/repo/deb/freeswitch-1.8/  stretch main" >> /etc/apt/sources.list.d/freeswitch.list

#upgrade packages
apt update && apt upgrade -y

# install dependencies
apt build-dep freeswitch -y

# additional dependencies
apt install -y sqlite3 swig3.0 unzip

#we are about to move out of the executing directory so we need to preserve it to return after we are done
CWD=$(pwd)
echo "Using version $switch_version"
cd /usr/src
#git clone -b v1.8 https://freeswitch.org/stash/scm/fs/freeswitch.git /usr/src/freeswitch
wget http://files.freeswitch.org/freeswitch-releases/freeswitch-$switch_version.zip
unzip freeswitch-$switch_version.zip
rm -R freeswitch
mv freeswitch-$switch_version freeswitch
cd /usr/src/freeswitch

# bootstrap is needed if using git
#./bootstrap.sh -j

# enable required modules
sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_avmd:applications/mod_avmd:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_callcenter:applications/mod_callcenter:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_cidlookup:applications/mod_cidlookup:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_memcache:applications/mod_memcache:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_curl:applications/mod_curl:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#formats/mod_shout:formats/mod_shout:'

# prepare the build
#./configure --prefix=/usr/local/freeswitch --enable-core-pgsql-support --disable-fhs
./configure -C --enable-portable-binary --disable-dependency-tracking \
--prefix=/usr --localstatedir=/var --sysconfdir=/etc \
--with-openssl --enable-core-pgsql-support

# compile and install
make
make install
make sounds-install moh-install
make hd-sounds-install hd-moh-install
make cd-sounds-install cd-moh-install

#move the music into music/default directory
mkdir -p /usr/share/freeswitch/sounds/music/default
mv /usr/share/freeswitch/sounds/music/*000 /usr/share/freeswitch/sounds/music/default

#return to the executing directory
cd $CWD
