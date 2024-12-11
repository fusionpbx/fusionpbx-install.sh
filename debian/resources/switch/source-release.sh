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
apt install -y libavformat-dev libswscale-dev libvlc-dev python3-distutils sox libsox-fmt-all

#install dependencies that depend on the operating system version
if [ ."$os_codename" = ."stretch" ]; then
	apt install -y libvpx4 swig3.0
fi
if [ ."$os_codename" = ."buster" ]; then
	apt install -y libvpx5 swig3.0
fi
if [ ."$os_codename" = ."bullseye" ]; then
	apt install -y libvpx6 swig4.0
fi

# additional dependencies
apt install -y sqlite3 unzip

#we are about to move out of the executing directory so we need to preserve it to return after we are done
CWD=$(pwd)

#install the following dependencies if the switch version is greater than 1.10.0
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
	./configure --enable-debug
	make -j $(getconf _NPROCESSORS_ONLN)
	make install

	# spandsp
	cd /usr/src
	git clone https://github.com/freeswitch/spandsp.git spandsp
	cd spandsp
 	git reset --hard 0d2e6ac65e0e8f53d652665a743015a88bf048d4
 	#/usr/bin/sed -i 's/AC_PREREQ(\[2\.71\])/AC_PREREQ([2.69])/g' /usr/src/spandsp/configure.ac
	sh autogen.sh
	./configure --enable-debug
	make -j $(getconf _NPROCESSORS_ONLN)
	make install
	ldconfig
fi

cd /usr/src

#check for master
if [ $switch_branch = "master" ]; then
	#master branch
	echo "Using version master"
	rm -r /usr/src/freeswitch
	git clone https://github.com/signalwire/freeswitch.git
	cd /usr/src/freeswitch
	./bootstrap.sh -j
fi

#check for stable release
if [ $switch_branch = "stable" ]; then
	echo "Using version $switch_version"
	#1.8 and older
	if [ $(echo "$switch_version" | tr -d '.') -lt 1100 ]; then
		wget http://files.freeswitch.org/freeswitch-releases/freeswitch-$switch_version.zip
		unzip freeswitch-$switch_version.zip
		cd /usr/src/freeswitch-$switch_version
	fi

	#1.10.0 and newer
	if [ $(echo "$switch_version" | tr -d '.') -gt 1100 ]; then
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
		#patch -u /usr/src/freeswitch-$switch_version/src/mod/databases/mod_pgsql/mod_pgsql.c -i /usr/src/fusionpbx-install.sh/debian/resources/switch/source/mod_pgsql.patch
	fi
fi

# enable required modules
#sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_avmd:applications/mod_avmd:'
sed -i /usr/src/freeswitch-$switch_version/modules.conf -e s:'#applications/mod_av:formats/mod_av:'
sed -i /usr/src/freeswitch-$switch_version/modules.conf -e s:'#applications/mod_callcenter:applications/mod_callcenter:'
sed -i /usr/src/freeswitch-$switch_version/modules.conf -e s:'#applications/mod_cidlookup:applications/mod_cidlookup:'
sed -i /usr/src/freeswitch-$switch_version/modules.conf -e s:'#applications/mod_memcache:applications/mod_memcache:'
sed -i /usr/src/freeswitch-$switch_version/modules.conf -e s:'#applications/mod_nibblebill:applications/mod_nibblebill:'
sed -i /usr/src/freeswitch-$switch_version/modules.conf -e s:'#applications/mod_curl:applications/mod_curl:'
sed -i /usr/src/freeswitch-$switch_version/modules.conf -e s:'#applications/mod_translate:applications/mod_translate:'
sed -i /usr/src/freeswitch-$switch_version/modules.conf -e s:'#formats/mod_shout:formats/mod_shout:'
sed -i /usr/src/freeswitch-$switch_version/modules.conf -e s:'#formats/mod_pgsql:formats/mod_pgsql:'
sed -i /usr/src/freeswitch-$switch_version/modules.conf -e s:'#say/mod_say_es:say/mod_say_es:'
sed -i /usr/src/freeswitch-$switch_version/modules.conf -e s:'#say/mod_say_fr:say/mod_say_fr:'

#disable module or install dependency libks to compile signalwire
sed -i /usr/src/freeswitch-$switch_version/modules.conf -e s:'applications/mod_signalwire:#applications/mod_signalwire:'
sed -i /usr/src/freeswitch-$switch_version/modules.conf -e s:'endpoints/mod_skinny:#endpoints/mod_skinny:'
sed -i /usr/src/freeswitch-$switch_version/modules.conf -e s:'endpoints/mod_verto:#endpoints/mod_verto:'

# prepare the build
#./configure --prefix=/usr/local/freeswitch --enable-core-pgsql-support --disable-fhs
./configure -C --enable-portable-binary --disable-dependency-tracking --enable-debug \
--prefix=/usr --localstatedir=/var --sysconfdir=/etc \
--with-openssl --enable-core-pgsql-support

# compile and install
make -j $(getconf _NPROCESSORS_ONLN)
make install

#return to the executing directory
cd $CWD
