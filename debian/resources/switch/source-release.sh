#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ../config.sh
. ../environment.sh

#upgrade packages
apt update && apt upgrade -y

# install dependencies
apt install -y autoconf automake devscripts g++ git-core libncurses5-dev libtool make libjpeg-dev 
apt install -y pkg-config flac  libgdbm-dev libdb-dev gettext sudo equivs mlocate git dpkg-dev libpq-dev
apt install -y liblua5.2-dev libtiff5-dev libperl-dev libcurl4-openssl-dev libsqlite3-dev libpcre3-dev
apt install -y devscripts libspeexdsp-dev libspeex-dev libldns-dev libedit-dev libopus-dev libmemcached-dev
apt install -y libshout3-dev libmpg123-dev libmp3lame-dev yasm nasm libsndfile1-dev libuv1-dev libvpx-dev
apt install -y libavformat-dev libswscale-dev

#install dependencies that depend on the operating system version
if [ ."$os_codename" = ."stretch" ]; then
	apt install -y libvpx4
fi
if [ ."$os_codename" = ."buster" ]; then
	apt install -y libvpx5
fi

# additional dependencies
apt install -y sqlite3 swig3.0 unzip

#we are about to move out of the executing directory so we need to preserve it to return after we are done
CWD=$(pwd)
echo "Using version $switch_version"
cd /usr/src
#git clone -b v1.8 https://freeswitch.org/stash/scm/fs/freeswitch.git /usr/src/freeswitch
#1.8 and older
#wget http://files.freeswitch.org/freeswitch-releases/freeswitch-$switch_version.zip
#1.10.0 and newer
wget http://files.freeswitch.org/freeswitch-releases/freeswitch-$switch_version.-release.zip
unzip freeswitch-$switch_version.-release.zip
rm -R freeswitch
mv freeswitch-$switch_version.-release freeswitch
cd /usr/src/freeswitch

# bootstrap is needed if using git
#./bootstrap.sh -j

# enable required modules
sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_avmd:applications/mod_avmd:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_callcenter:applications/mod_callcenter:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_cidlookup:applications/mod_cidlookup:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_memcache:applications/mod_memcache:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_nibblebill:applications/mod_nibblebill:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_curl:applications/mod_curl:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#formats/mod_shout:formats/mod_shout:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#formats/mod_pgsql:formats/mod_pgsql:'

#disable module or install dependency libks to compile signalwire
sed -i /usr/src/freeswitch/modules.conf -e s:'applications/mod_signalwire:#applications/mod_signalwire:'

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
