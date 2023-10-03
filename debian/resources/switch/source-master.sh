#!/bin/sh
echo "Installing the FreeSWITCH source"
DEBIAN_FRONTEND=none APT_LISTCHANGES_FRONTEND=none apt-get install -y ntpdate libapache2-mod-log-sql-ssl libfreetype6-dev git-buildpackage doxygen yasm nasm gdb git build-essential automake autoconf 'libtool-bin|libtool' python uuid-dev zlib1g-dev 'libjpeg8-dev|libjpeg62-turbo-dev' libncurses5-dev libssl-dev libpcre3-dev libcurl4-openssl-dev libldns-dev libedit-dev libspeexdsp-dev libspeexdsp-dev libsqlite3-dev perl libgdbm-dev libdb-dev bison libvlc-dev libvlccore-dev vlc-nox pkg-config ccache libpng-dev libvpx-dev libyuv-dev libopenal-dev libbroadvoice-dev libcodec2-dev libflite-dev libg7221-dev libilbc-dev libmongoc-dev libsilk-dev libsoundtouch-dev libmagickcore-dev liblua5.2-dev libopus-dev libsndfile-dev libopencv-dev libavformat-dev libx264-dev erlang-dev libldap2-dev libmemcached-dev libperl-dev portaudio19-dev python-dev libsnmp-dev libyaml-dev libmp4v2-dev
apt-get install -y unzip libpq-dev libvlc-dev memcached libshout3-dev libvpx-dev libmpg123-dev libmp3lame-dev

apt-get update && apt-get install -y ntp curl haveged
curl https://files.freeswitch.org/repo/deb/debian/freeswitch_archive_g0.pub | apt-key add -
echo "deb http://files.freeswitch.org/repo/deb/freeswitch-1.6/ jessie main" > /etc/apt/sources.list.d/freeswitch.list
echo "deb http://files.freeswitch.org/repo/deb/debian-unstable/ jessie main" > /etc/apt/sources.list.d/freeswitch.list
apt-get update && apt-get upgrade
apt-get install -y freeswitch-video-deps-most

git clone https://freeswitch.org/stash/scm/fs/freeswitch.git /usr/src/freeswitch
cd /usr/src/freeswitch

sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_avmd:applications/mod_avmd:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_callcenter:applications/mod_callcenter:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_cidlookup:applications/mod_cidlookup:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_memcache:applications/mod_memcache:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_curl:applications/mod_curl:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#formats/mod_shout:formats/mod_shout:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#formats/mod_pgsql:formats/mod_pgsql:'
./bootstrap.sh -j
#./configure --prefix=/usr/local/freeswitch --enable-core-pgsql-support --enable-system-lua --disable-fhs
./configure --prefix=/usr/local/freeswitch --enable-core-pgsql-support --disable-fhs

#make mod_shout-install
make -j $(getconf _NPROCESSORS_ONLN)
rm -rf /usr/local/freeswitch/{lib,mod,bin}/*
make install
make sounds-install moh-install
make hd-sounds-install hd-moh-install
make cd-sounds-install cd-moh-install

#move the music into music/default directory
mkdir -p /usr/local/freeswitch/sounds/music/default
mv /usr/local/freeswitch/sounds/music/*000 /usr/local/freeswitch/sounds/music/default

#configure system service
ln -s /usr/local/freeswitch/bin/fs_cli /usr/bin/fs_cli
cp "$(dirname $0)/source/freeswitch.service" /lib/systemd/system/freeswitch.service
