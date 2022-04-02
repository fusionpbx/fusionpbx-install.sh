#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ../config.sh

#upgrade packages
apt update && apt upgrade -y

# install dependencies
apt install -y autoconf automake devscripts g++ git-core libncurses5-dev libtool make libjpeg-dev \
  pkg-config flac  libgdbm-dev libdb-dev gettext sudo equivs mlocate git dpkg-dev libpq-dev \
  liblua5.2-dev libtiff5-dev libperl-dev libcurl4-openssl-dev libsqlite3-dev libpcre3-dev \
  devscripts libspeexdsp-dev libspeex-dev libldns-dev libedit-dev libopus-dev libmemcached-dev \
  libshout3-dev libmpg123-dev libmp3lame-dev yasm nasm libsndfile1-dev libuv1-dev libvpx-dev \
  libavformat-dev libswscale-dev libspandsp-dev pip libpq-dev libvlc-dev

# additional dependencies
apt install -y swig3.0 unzip sox wget

#we are about to move out of the executing directory so we need to preserve it to return after we are done
CWD=$(pwd)

if [ $(echo "$switch_version" | tr -d '.') -gt 1103 ]
then
# libks build-requirements
#apt install -y cmake uuid-dev

# libks
#cd /usr/src
#git clone https://github.com/signalwire/libks.git libks
#cd libks
#cmake .
#make
#make install

# libks C includes
#export C_INCLUDE_PATH=/usr/include/libks

# sofia-sip
cd /usr/src
#git clone https://github.com/freeswitch/sofia-sip.git sofia-sip
wget https://github.com/freeswitch/sofia-sip/archive/refs/tags/v$sofia_version.zip
unzip v$sofia_version.zip
rm -R sofia-sip
mv sofia-sip-$sofia_version sofia-sip
cd sofia-sip
sh autogen.sh
./configure
make
make install

# spandsp
cd /usr/src
git clone https://github.com/freeswitch/spandsp.git spandsp
cd spandsp
sh autogen.sh
./configure
make
make install
ldconfig
fi

echo "Using version $switch_version"
cd /usr/src
#git clone -b v1.8 https://freeswitch.org/stash/scm/fs/freeswitch.git /usr/src/freeswitch
#1.8 and older
#wget http://files.freeswitch.org/freeswitch-releases/freeswitch-$switch_version.zip
#unzip freeswitch-$switch_version.zip
#rm -R freeswitch
#mv freeswitch-$switch_version freeswitch
#cd /usr/src/freeswitch
#1.10.0 and newer
wget http://files.freeswitch.org/freeswitch-releases/freeswitch-$switch_version.-release.zip -O freeswitch-$switch_version.-release.zip
unzip freeswitch-$switch_version.-release.zip
rm -R freeswitch
mv freeswitch-$switch_version.-release freeswitch
cd /usr/src/freeswitch

# bootstrap is needed if using git
#./bootstrap.sh -j

# enable required modules
sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_callcenter:applications/mod_callcenter:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_cidlookup:applications/mod_cidlookup:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_memcache:applications/mod_memcache:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_curl:applications/mod_curl:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#formats/mod_shout:formats/mod_shout:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#formats/mod_pgsql:formats/mod_pgsql:'
sed -i /usr/src/freeswitch/modules.conf -e s:'endpoints/mod_verto:#endpoints/mod_verto:'
#sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_avmd:applications/mod_avmd:'

#disable module or install dependency libks to compile signalwire
sed -i /usr/src/freeswitch/modules.conf -e s:'applications/mod_signalwire:#applications/mod_signalwire:'

# prepare the build
#./configure --prefix=/usr/local/freeswitch --enable-core-pgsql-support --disable-fhs
./configure -C --enable-portable-binary --disable-dependency-tracking \
--prefix=/usr --localstatedir=/var --sysconfdir=/etc \
--with-openssl --enable-core-pgsql-support

# compile and install
make

rm -rf /usr/share/freeswitch/sounds/music/default

make install
make sounds-install moh-install
make hd-sounds-install hd-moh-install
make cd-sounds-install cd-moh-install

#move the music into music/default directory
mkdir -p /usr/share/freeswitch/sounds/music/default
mv /usr/share/freeswitch/sounds/music/*000 /usr/share/freeswitch/sounds/music/default

#return to the executing directory
cd $CWD
