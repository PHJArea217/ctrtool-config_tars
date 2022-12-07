#!/bin/sh
set -eu
ip route add blackhole 23.161.208.0/24
ip route add blackhole "2602:806:a000::/48"
iptables-nft-restore <<\EOF
*filter
:CHAIN1 -
-A CHAIN1 -s 100.64.0.0/10 -j DROP
-A CHAIN1 -d 100.64.0.0/10 -j DROP
-A CHAIN1 -p tcp --dport 25 -o ens3 -j DROP
-A OUTPUT -j CHAIN1
-A FORWARD -j CHAIN1
COMMIT
EOF
ip6tables-nft-restore <<\EOF
*filter
:CHAIN1
-A CHAIN1 -p tcp --dport 25 -o ens3 -j DROP
-A OUTPUT -j CHAIN1
-A FORWARD -j CHAIN1
COMMIT
EOF
sysctl -w 'net.ipv4.ip_forward=1' 'net.ipv6.conf.all.forwarding=1'
