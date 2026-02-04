#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#add the includes
. ./config.sh
. ./colors.sh
. ./environment.sh

#send a message
verbose "Configuring nftables"

#download the latest package index
apt update

#install nftables
apt install nftables -y

#remove iptables
apt purge iptables-persistent -y
rm -rf /etc/iptables

#run iptables commands
cat << EOF > /etc/nftables.conf
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0;
        policy drop;

        # Block specific IP addresses
        #ip saddr 10.1.0.3 drop

        # Allow loopback interface traffic
        iifname "lo" counter accept

        # Accept related and established connections
        ct state related,established counter accept

        # Allow SSH port
        tcp dport 22 counter accept

        # Allow HTTP/HTTPS
        tcp dport {80,443} counter accept

        # Secure Websocket port
        tcp dport 7443 counter accept

        # Allow SIP ports
        tcp dport 5060-5091 counter accept
        udp dport 5060-5091 counter accept

        # Allow RTP Media ports
        udp dport 16384-32768 counter accept

        # Accept ICMP echo requests (ping)
        icmp type echo-request counter accept

        # Allow OpenVPN port
        udp dport 1194 counter accept
    }

    chain forward {
        type filter hook forward priority 0;
        policy drop;
    }

    chain output {
        type filter hook output priority 0;
        policy accept;
    }

        chain sip-auth-ip {
                type filter hook input priority -50;
                policy accept;

                # Block specific IP addresses
                #ip saddr 10.1.0.3 counter drop
        }

        chain sip-auth-fail {
                type filter hook input priority -50;
                policy accept;
        }

}

table inet mangle {
    chain output {
        type route hook output priority -150;

        # Set DSCP value for TCP and UDP traffic from source ports
        tcp sport 5060-5091 counter ip dscp set 0x1a
        udp sport 5060-5091 counter ip dscp set 0x1a

        # Set DSCP value for UDP traffic from source ports
        udp sport 16384-32768 counter ip dscp set 0x2e

        policy accept;
    }
}
EOF

#enable nftables and start the service
systemctl enable nftables
systemctl start nftables

#load the nftable configuration
nft -f /etc/nftables.conf

