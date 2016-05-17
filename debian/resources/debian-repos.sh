#######################################
#Setup Main debian repo for right pkgs
#######################################
echo "installing jessie release repo"
cat > "/etc/apt/sources.list" << DELIM
deb http://httpredir.debian.org/debian/ jessie main contrib non-free
deb-src http://httpredir.debian.org/debian/ jessie main contrib non-free

deb http://httpredir.debian.org/debian/ jessie-updates main contrib non-free
deb-src http://httpredir.debian.org/debian/ jessie-updates main contrib non-free

deb http://httpredir.debian.org/debian/ jessie-backports main contrib non-free
deb-src http://httpredir.debian.org/debian/ jessie-backports main contrib non-free
DELIM

####################################
#----- upgrading base install-----
####################################
apt-get update && apt-get -y upgrade