#!/bin/sh
set -eu
ip link add "$1" type bridge
for _addr in $2; do ip addr add "$_addr" dev "$1"; done
ip link set "$1" up
sysctl -w net.ipv6.conf.all.forwarding=1
