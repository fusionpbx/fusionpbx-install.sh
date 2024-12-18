#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ../config.sh

#upgrade packages
apt update && apt upgrade -y

# install dependencies
apt install -y autoconf automake devscripts g++ git-core libncurses5-dev libtool make libjpeg-dev pkg-config flac  libgdbm-dev libdb-dev gettext sudo equivs plocate git dpkg-dev libpq-dev liblua5.2-dev libtiff5-dev libperl-dev libcurl4-openssl-dev libsqlite3-dev libpcre3-dev devscripts libspeexdsp-dev libspeex-dev libldns-dev libedit-dev libopus-dev libmemcached-dev libshout3-dev libmpg123-dev libmp3lame-dev yasm nasm libsndfile1-dev libuv1-dev libvpx-dev libavformat-dev libswscale-dev libspandsp-dev pip libpq-dev libvlc-dev uuid-dev sox libsox-fmt-all

# additional dependencies
apt install -y swig3.0 unzip sox wget

#we are about to move out of the executing directory so we need to preserve it to return after we are done
CWD=$(pwd)

if [ $(echo "$switch_version" | tr -d '.') -gt 1100 ]; then
	# libks build-requirements
	apt install -y cmake uuid-dev

	# libks
	cd /usr/src
	git clone https://github.com/signalwire/libks.git libks
	cd libks
	cmake .
	make -j $(getconf _NPROCESSORS_ONLN)
	make install

	# libks C includes
	export C_INCLUDE_PATH=/usr/include/libks
 
	# sofia-sip
	cd /usr/src
	#git clone https://github.com/freeswitch/sofia-sip.git sofia-sip
	wget https://github.com/freeswitch/sofia-sip/archive/refs/tags/v$sofia_version.zip
	unzip v$sofia_version.zip
	cd sofia-sip-$sofia_version
	sh autogen.sh
	./configure
	make
	make install
	
	# spandsp
	cd /usr/src
	git clone https://github.com/freeswitch/spandsp.git spandsp
	cd spandsp
	git reset --hard 0d2e6ac65e0e8f53d652665a743015a88bf048d4
	/usr/bin/sed -i 's/AC_PREREQ(\[2\.71\])/AC_PREREQ([2.69])/g' /usr/src/spandsp/configure.ac
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
if [ $(echo "$switch_version" | tr -d '.') -lt 1100 ]; then
	wget http://files.freeswitch.org/freeswitch-releases/freeswitch-$switch_version.zip
	unzip freeswitch-$switch_version.zip
	cd /usr/src/freeswitch-$switch_version
fi

#1.10.0 and newer
if [ $(echo "$switch_version" | tr -d '.') -gt 1100 ]; then
	#use git to get the source code and checkout the current branch
	git clone -b $switch_version --single-branch https://github.com/fusionpbx/freeswitch freeswitch-$switch_version
	git checkout $switch_version

	#wget http://files.freeswitch.org/freeswitch-releases/freeswitch-$switch_version.-release.zip
	#unzip freeswitch-$switch_version.-release.zip
	#mv freeswitch-$switch_version.-release freeswitch-$switch_version
 
	cd /usr/src/freeswitch-$switch_version

	# bootstrap is needed if using git
	./bootstrap.sh -j
  
	#apply rtp timestamp patch - Fix RTP audio issues use the following for additional information. https://github.com/briteback/freeswitch/commit/9f8968ccabb8a4e0353016d4ea0ff99561b005f1
	#patch -u /usr/src/freeswitch-$switch_version/src/switch_rtp.c -i /usr/src/fusionpbx-install.sh/debian/resources/switch/source/switch_rtp.diff

	#apply pull request 2300 to Fix session deadlock that results in stale or stuck calls. https://github.com/signalwire/freeswitch/pull/2300
	#patch -d /usr/src/freeswitch-$switch_version/src -i /usr/src/fusionpbx-install.sh/debian/resources/switch/source/pull_2300.diff

	#apply mod_pgsql patch
	#patch -u /usr/src/freeswitch-$switch_version/src/mod/databases/mod_pgsql/mod_pgsql.c -i /usr/src/fusionpbx-install.sh/ubuntu/resources/switch/source/mod_pgsql.patch
fi

# enable required modules
sed -i /usr/src/freeswitch-$switch_version/modules.conf -e s:'#applications/mod_callcenter:applications/mod_callcenter:'
sed -i /usr/src/freeswitch-$switch_version/modules.conf -e s:'#applications/mod_cidlookup:applications/mod_cidlookup:'
sed -i /usr/src/freeswitch-$switch_version/modules.conf -e s:'#applications/mod_memcache:applications/mod_memcache:'
sed -i /usr/src/freeswitch-$switch_version/modules.conf -e s:'#applications/mod_curl:applications/mod_curl:'
sed -i /usr/src/freeswitch-$switch_version/modules.conf -e s:'#formats/mod_shout:formats/mod_shout:'
sed -i /usr/src/freeswitch-$switch_version/modules.conf -e s:'#formats/mod_pgsql:formats/mod_pgsql:'
sed -i /usr/src/freeswitch-$switch_version/modules.conf -e s:'endpoints/mod_verto:#endpoints/mod_verto:'
#sed -i /usr/src/freeswitch-$switch_version/modules.conf -e s:'#applications/mod_avmd:applications/mod_avmd:'

#disable module or install dependency libks to compile signalwire
sed -i /usr/src/freeswitch-$switch_version/modules.conf -e s:'applications/mod_signalwire:#applications/mod_signalwire:'
sed -i /usr/src/freeswitch-$switch_version/modules.conf -e s:'applications/mod_av:#applications/mod_av:'

# prepare the build
#./configure --prefix=/usr/local/freeswitch --enable-core-pgsql-support --disable-fhs
./configure -C --enable-portable-binary --disable-dependency-tracking \
--prefix=/usr --localstatedir=/var --sysconfdir=/etc \
--with-openssl --enable-core-pgsql-support

# compile and install
make
make install

#return to the executing directory
cd $CWD
