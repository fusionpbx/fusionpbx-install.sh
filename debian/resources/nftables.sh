#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#add the includes
. ./config.sh
. ./colors.sh
. ./environment.sh

#send a message
verbose "Configuring nftables"

#run iptables commands
nft add rule ip filter INPUT iifname "lo" counter accept
nft add rule ip filter INPUT ct state related,established  counter accept
nft add rule ip filter INPUT tcp dport 22 counter accept
nft add rule ip filter INPUT tcp dport 80 counter accept
nft add rule ip filter INPUT tcp dport 443 counter accept
nft add rule ip filter INPUT tcp dport 7443 counter accept
nft add rule ip filter INPUT tcp dport 5060-5091 counter accept
nft add rule ip filter INPUT udp dport 5060-5091 counter accept
nft add rule ip filter INPUT udp dport 16384-32768 counter accept
nft add rule ip filter INPUT icmp type echo-request counter accept
nft add rule ip filter INPUT udp dport 1194 counter accept
nft add rule ip mangle OUTPUT udp sport 16384-32768 counter ip dscp set 0x2e
nft add rule ip mangle OUTPUT tcp sport 5060-5091 counter ip dscp set 0x1a
nft add rule ip mangle OUTPUT udp sport 5060-5091 counter ip dscp set 0x1a


