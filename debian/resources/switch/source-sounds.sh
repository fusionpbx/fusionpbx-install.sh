#!/bin/sh

# Move to script directory so all relative paths work
cd "$(dirname "$0")"

# Includes
. ../config.sh
. ../environment.sh

# Change the working directory
cd /usr/share/freeswitch/sounds

# Array of sample rates
sample_rates="48000 32000 16000 8000"

# Loop through each sample rate
for sample_rate in $sample_rates; do
    # Download the file
    wget "https://files.freeswitch.org/releases/sounds/freeswitch-sounds-en-us-callie-${sample_rate}-1.0.53.tar.gz"

    # Extract the file
    tar xvzf "freeswitch-sounds-en-us-callie-${sample_rate}-1.0.53.tar.gz"
done

# Change to directory to the music directory
cd /usr/share/freeswitch/sounds/music

# Loop through each sample rate
for sample_rate in $sample_rates; do
    # Download the file
    wget "https://files.freeswitch.org/releases/sounds/freeswitch-sounds-music-${sample_rate}-1.0.52.tar.gz"

    # Extract the file
    tar xvzf "freeswitch-sounds-music-${sample_rate}-1.0.52.tar.gz"
done

# Move the music to the default directory
mv music default

# Remove the tar.gz files
rm /usr/share/freeswitch/sounds/music/*.tar.gz
