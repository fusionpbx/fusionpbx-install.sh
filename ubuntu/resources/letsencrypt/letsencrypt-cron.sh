#!/bin/sh

dh="/usr/local/sbin/dehydrated"
$dh --cron
$dh --cleanup

# generate all.pem
all_path=$(readlink -f /etc/freeswitch/tls/all.pem)
all_dir=$(dirname "$all_path")
cat "$all_dir/fullchain.pem" > "$all_path"
cat "$all_dir/privkey.pem" >> "$all_path"
chmod a+r "$all_dir"/*
