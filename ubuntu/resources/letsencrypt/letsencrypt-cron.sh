#!/usr/bin/env sh
# Cert renewal cron script for dehydrated.
# You will need to deploy a dehydrated hook script for your DNS provider
#  if using a dns-01 challenge

set -u
dh="/usr/local/sbin/dehydrated"
tmp=$(mktemp)
$dh --cron > $tmp
dh_fail=$?
cat $tmp
grep "Skipping renew" "$tmp" >/dev/null
grep_fail=$?
rm $tmp

if [ ${dh_fail} -eq 0 ]; then
  if [ ${grep_fail} -eq 0 ]; then
    echo "Certificate is fresh!"
    exit 0
  else
    echo "Certificate renewed!" >&2
    service nginx reload
  fi
else
  echo "Certificate renew failed." >&2
  exit 1
fi
$dh --cleanup

# generate all.pem
all_path=$(readlink -f /etc/freeswitch/tls/tls.pem)
all_dir=$(dirname "$all_path")
cat "$all_dir/fullchain.pem" > "$all_path"
cat "$all_dir/privkey.pem" >> "$all_path"
chmod 640 $all_dir/*
