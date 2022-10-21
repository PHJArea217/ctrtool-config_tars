#!/bin/sh
set -eu
unshare -n sh -eu -c 'ip link set lo up
ip route add unreachable "::/0"
sysctl -w net.ipv6.conf.all.forwarding=1 net.ipv6.conf.all.accept_ra=0 net.ipv6.conf.default.accept_ra=0
:>/run/netns/u-relay-main
mount --bind /proc/self/ns/net /run/netns/u-relay-main'
