#!/bin/sh

# Move to script directory so all relative paths work
cd "$(dirname "$0")"

# Includes
. ../config.sh
. ../environment.sh

# Make the sounds directory
mkdir -p /usr/share/freeswitch/sounds

# Change the working directory
cd /usr/share/freeswitch/sounds

# Make sure wget is installed
apt-get install -y wget

# Array of sample rates
sample_rates="48000 32000 16000 8000"

# Loop through each sample rate
for sample_rate in $sample_rates; do
    # Download the file
    /usr/bin/wget "https://files.freeswitch.org/releases/sounds/freeswitch-sounds-en-us-callie-${sample_rate}-1.0.53.tar.gz"

    # Extract the file
    /usr/bin/tar xvzf "freeswitch-sounds-en-us-callie-${sample_rate}-1.0.53.tar.gz"
done

# Make the music directory
mkdir -p /usr/share/freeswitch/sounds/music

# Change the current directory to the music directory
cd /usr/share/freeswitch/sounds/music

# Loop through each sample rate
for sample_rate in $sample_rates; do
    # Download the file
    /usr/bin/wget "https://files.freeswitch.org/releases/sounds/freeswitch-sounds-music-${sample_rate}-1.0.52.tar.gz"

    # Extract the file
    /usr/bin/tar xvzf "freeswitch-sounds-music-${sample_rate}-1.0.52.tar.gz"
done

# Move the music to the default directory
/usr/bin/mv music default

# Remove the tar.gz files
/usr/bin/rm /usr/share/freeswitch/sounds/music/*.tar.gz
