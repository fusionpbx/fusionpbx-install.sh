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
apt install -y libavformat-dev libswscale-dev libvlc-dev python3-distutils

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
	make
	make install

	# libks C includes
	export C_INCLUDE_PATH=/usr/include/libks

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
		rm -R freeswitch
		unzip freeswitch-$switch_version.zip
		mv freeswitch-$switch_version freeswitch
		cd /usr/src/freeswitch
	fi

	#1.10.0 and newer
	if [ $(echo "$switch_version" | tr -d '.') -gt 1100 ]; then
		wget http://files.freeswitch.org/freeswitch-releases/freeswitch-$switch_version.-release.zip
		unzip freeswitch-$switch_version.-release.zip
		rm -R freeswitch
		mv freeswitch-$switch_version.-release freeswitch
		cd /usr/src/freeswitch
		#apply patch
		#patch -u /usr/src/freeswitch/src/mod/databases/mod_pgsql/mod_pgsql.c -i /usr/src/fusionpbx-install.sh/debian/resources/switch/source/mod_pgsql.patch
	fi
fi

# enable required modules
#sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_avmd:applications/mod_avmd:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_av:formats/mod_av:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_callcenter:applications/mod_callcenter:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_cidlookup:applications/mod_cidlookup:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_memcache:applications/mod_memcache:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_nibblebill:applications/mod_nibblebill:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_curl:applications/mod_curl:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#formats/mod_shout:formats/mod_shout:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#formats/mod_pgsql:formats/mod_pgsql:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#say/mod_say_es:say/mod_say_es:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#say/mod_say_fr:say/mod_say_fr:'

#disable module or install dependency libks to compile signalwire
sed -i /usr/src/freeswitch/modules.conf -e s:'applications/mod_signalwire:#applications/mod_signalwire:'
sed -i /usr/src/freeswitch/modules.conf -e s:'endpoints/mod_skinny:#endpoints/mod_skinny:'
sed -i /usr/src/freeswitch/modules.conf -e s:'endpoints/mod_verto:#endpoints/mod_verto:'

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
