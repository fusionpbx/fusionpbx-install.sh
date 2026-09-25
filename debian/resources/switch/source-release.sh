#!/bin/sh

# Move to script directory so all relative paths work
cd "$(dirname "$0")"

# Includes
. ../config.sh
. ../environment.sh

# Upgrade packages
apt update && apt upgrade -y

# Install dependencies
apt install -y autoconf automake devscripts g++ git-core libncurses5-dev libtool libtool-bin make libjpeg-dev
apt install -y pkg-config flac  libgdbm-dev libdb-dev gettext sudo equivs git dpkg-dev libpq-dev
apt install -y liblua5.2-dev libtiff5-dev libperl-dev libcurl4-openssl-dev libsqlite3-dev
apt install -y devscripts libspeexdsp-dev libspeex-dev libldns-dev libedit-dev libopus-dev libmemcached-dev
apt install -y libshout3-dev libmpg123-dev libmp3lame-dev yasm nasm libsndfile1-dev libuv1-dev libvpx-dev
apt install -y libavformat-dev libswscale-dev libvlc-dev sox libsox-fmt-all
apt install -y libtiff5-dev
apt install -y libpcre3-dev

# Install dependencies that depend on the operating system version
if [ ."$os_codename" = ."noble" ]; then
	apt install -y python3-distutils mlocate libvpx9 swig3.0
fi
if [ ."$os_codename" = ."stretch" ]; then
	apt install -y python3-distutils mlocate libvpx4 swig3.0
fi
if [ ."$os_codename" = ."buster" ]; then
	apt install -y python3-distutils mlocate libvpx5 swig3.0
fi
if [ ."$os_codename" = ."bullseye" ]; then
	apt install -y python3-distutils mlocate libvpx6 swig4.0
fi
if [ ."$os_codename" = ."trixie" ]; then
	apt install -y python3-distutils-extra plocate libtiff-dev libpcre2-dev swig
fi

# Additional dependencies
apt install -y sqlite3 unzip

# Preserve the executing directory, so we need to return after we are done
CWD=$(pwd)

# Remove libks if it is older than 24 hours
find /usr/src/libks -maxdepth 0 -mtime +1 -exec rm -rf {} \; 2>/dev/null

# Install libks - dependency for switch versions greater than 1.10.0
if [ ! -d /usr/src/libks ]; then

	# libks build-requirements
	apt install -y cmake uuid-dev

	# libks
	cd /usr/src
	git clone https://github.com/signalwire/libks.git libks
	cd libks
	cmake .
	make -j $(getconf _NPROCESSORS_ONLN)
	make install
	ldconfig

	# libks C includes
	export C_INCLUDE_PATH=/usr/include/libks
fi

# Remove sofia-sip if it is older than 24 hours
find /usr/src/sofia-sip -maxdepth 0 -mtime +1 -exec rm -rf {} \; 2>/dev/null

# sofia-sip - dependency for switch versions greater than 1.10.0
if [ ! -d /usr/src/sofia-sip ]; then
	cd /usr/src
	if [ ."$sofia_version" = ."master" ]; then
		git clone https://github.com/freeswitch/sofia-sip.git sofia-sip
		cd sofia-sip
	elif [ ."$os_codename" = ."trixie" ]; then
		git clone https://github.com/freeswitch/sofia-sip.git sofia-sip
		cd sofia-sip
	else
		wget https://github.com/freeswitch/sofia-sip/archive/refs/tags/v$sofia_version.zip
		unzip v$sofia_version.zip
		mv sofia-sip-$sofia_version sofia-sip
		cd sofia-sip
	fi
	sh autogen.sh
	./configure --enable-debug
	make -j $(getconf _NPROCESSORS_ONLN)
	make install
	ldconfig
fi

# Remove spandsp if it is older than 24 hours
find /usr/src/spandsp -maxdepth 0 -mtime +1 -exec rm -rf {} \; 2>/dev/null

# spandsp - dependency for switch versions greater than 1.10.0
if [ ! -d /usr/src/spandsp ]; then
	cd /usr/src
	git clone https://github.com/freeswitch/spandsp.git spandsp
	cd spandsp
	if [ ."$sofia_version" != ."master" ]; then
		echo ""
	elif [ ."$os_codename" = ."trixie" ]; then
		echo ""
	else
		git reset --hard 0d2e6ac65e0e8f53d652665a743015a88bf048d4
	fi
	#/usr/bin/sed -i 's/AC_PREREQ(\[2\.71\])/AC_PREREQ([2.69])/g' /usr/src/spandsp/configure.ac
	sh autogen.sh
	./configure --enable-debug
	make -j $(getconf _NPROCESSORS_ONLN)
	make install
	ldconfig
fi

cd /usr/src

# Check for master
if [ ."$switch_branch" = ."master" ]; then
	#master branch
	echo "Using version master"
	rm -r /usr/src/freeswitch-$switch_version
	git clone https://github.com/signalwire/freeswitch.git freeswitch-$switch_version
	cd /usr/src/freeswitch-$switch_version

	git remote add fusionpbx https://github.com/fusionpbx/freeswitch.git
	git fetch fusionpbx
	git checkout 1.10.12

	git rebase fusionpbx/master
	./bootstrap.sh -j
fi

# Check for stable release
if [ ."$switch_branch" != ."master" ] && [ ."$switch_branch" = ."stable" ]; then
	echo "Using version $switch_version"
	rm -rf /usr/src/freeswitch-$switch_version

	# Get the source code using git
	if [ ."$switch_version" = ."1.11" ]; then
	    git clone https://github.com/signalwire/freeswitch.git freeswitch-$switch_version

		# Change the working directory
		cd /usr/src/freeswitch-$switch_version

		# Get the stable branch
		git checkout v$switch_version
	fi

	# Get the source code using git
	if [ ."$switch_version" = ."1.10.12" ]; then
		git clone https://github.com/fusionpbx/freeswitch freeswitch-$switch_version

		# Change the working directory
		cd /usr/src/freeswitch-$switch_version

		# Get the stable branch
		git checkout $switch_version
	fi

	# Reset repo just-in-case we are rebuilding
	#git reset --hard origin/master && git clean -fdx

	# wget http://files.freeswitch.org/freeswitch-releases/freeswitch-$switch_version.-release.zip
	# unzip freeswitch-$switch_version.-release.zip
	# mv freeswitch-$switch_version.-release freeswitch-$switch_version

	# Bootstrap is needed if using git
	./bootstrap.sh -j

	# Apply RTP timestamp patch - Fix RTP audio issues use the following for additional information. https://github.com/briteback/freeswitch/commit/9f8968ccabb8a4e0353016d4ea0ff99561b005f1
	#patch -u /usr/src/freeswitch-$switch_version/src/switch_rtp.c -i /usr/src/fusionpbx-install.sh/debian/resources/switch/source/switch_rtp.diff

	# Apply pull request 2300 to fix session deadlock that results in stale or stuck calls. https://github.com/signalwire/freeswitch/pull/2300
	#patch -d /usr/src/freeswitch-$switch_version/src -i /usr/src/fusionpbx-install.sh/debian/resources/switch/source/pull_2300.diff

	#apply mod_pgsql patch
	#patch -u /usr/src/freeswitch-$switch_version/src/mod/databases/mod_pgsql/mod_pgsql.c -i /usr/src/fusionpbx-install.sh/debian/resources/switch/source/mod_pgsql.patch
fi

# Enable required modules
#sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_avmd:applications/mod_avmd:'
sed -i modules.conf -e s:'#applications/mod_av:formats/mod_av:'
sed -i modules.conf -e s:'#applications/mod_callcenter:applications/mod_callcenter:'
sed -i modules.conf -e s:'#applications/mod_cidlookup:applications/mod_cidlookup:'
sed -i modules.conf -e s:'#applications/mod_memcache:applications/mod_memcache:'
sed -i modules.conf -e s:'#applications/mod_nibblebill:applications/mod_nibblebill:'
sed -i modules.conf -e s:'#applications/mod_curl:applications/mod_curl:'
sed -i modules.conf -e s:'#applications/mod_translate:applications/mod_translate:'
sed -i modules.conf -e s:'#formats/mod_shout:formats/mod_shout:'
sed -i modules.conf -e s:'#formats/mod_pgsql:formats/mod_pgsql:'
sed -i modules.conf -e s:'#say/mod_say_es:say/mod_say_es:'
sed -i modules.conf -e s:'#say/mod_say_fr:say/mod_say_fr:'

# Disable module or install dependency libks to compile signalwire
sed -i modules.conf -e s:'applications/mod_signalwire:#applications/mod_signalwire:'
sed -i modules.conf -e s:'endpoints/mod_skinny:#endpoints/mod_skinny:'
sed -i modules.conf -e s:'endpoints/mod_verto:#endpoints/mod_verto:'

# Enable TLS certificate reload support (fs_cli: reloadcert)
export CPPFLAGS="${CPPFLAGS} -DHAVE_NUA_RELOAD_TLS"

# Prepare the build
#./configure --prefix=/usr/local/freeswitch --enable-core-pgsql-support --disable-fhs
./configure -C --enable-portable-binary --disable-dependency-tracking --enable-debug \
--prefix=/usr --localstatedir=/var --sysconfdir=/etc \
--with-openssl --enable-core-pgsql-support

# Compile and install
make -j $(getconf _NPROCESSORS_ONLN)
make install

# Create voicemail directory for installer
mkdir -p /var/lib/freeswitch/storage/voicemail

# Return to the executing directory
cd $CWD
