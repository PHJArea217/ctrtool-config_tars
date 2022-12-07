#!/bin/sh
set -eu
GITREPOS="/__autoserver-local__/server1/gitrepos"
"$GITREPOS/ctrtool-containers/misc/netns-tool" 'mode=l3_system' routes_err="2602:806:a000:2000::/51 23.161.208.0/26 23.161.208.248/29 100.78.0.0/16" routes_local="2602:806:a000:2000::/64 23.161.208.0/28" address="23.161.208.8 2602:806:a000:4000::1" local_addr="100.79.0.1" netns=inner local_if=to_inner
nsenter --net="/run/netns/inner" sh -c '
set -eu
"$GITREPOS/ctrtool-containers/misc/netns-tool" "mode=l3_system" routes_err="2602:806:a000:2800::/54 100.78.0.0/17 23.161.208.248/30" address="2602:806:a000:2001::1 23.161.208.254" local_addr="23.161.208.255" netns="innerfw" local_if="to_innerfw"
sysctl -w net.ipv6.conf.all.forwarding=1 net.ipv4.ip_forward=1'
nsenter --net="/run/netns/innerfw" sh -c 'set -eu
if :; then
iptables-nft-restore <<\EOF
*mangle
-A PREROUTING -i wg0 -p tcp -j TCPMSS --set-mss 1380
-A POSTROUTING -o wg0 -p tcp -j TCPMSS --set-mss 1380
COMMIT
*nat
:WEBSERVER -
-A PREROUTING -i eth0 -d 23.161.208.254 -j WEBSERVER
-A WEBSERVER -p tcp -m multiport --dports 53,80,443 -j DNAT --to 100.78.20.64
-A WEBSERVER -p udp -m multiport --dports 53 -j DNAT --to 100.78.20.64
-A POSTROUTING -o eth0 -s 100.78.0.0/17 -j NETMAP --to 23.161.208.248/30
COMMIT
*filter
:WEBSERVER -
:FORWARD DROP
-A FORWARD -i eth0 ! -o eth0 -d 100.78.20.64 -j WEBSERVER
-A WEBSERVER -p tcp -m multiport --dports 53,80,443 -j ACCEPT
-A WEBSERVER -p udp -m multiport --dports 53 -j ACCEPT
-A FORWARD -i eth0 ! -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
-A FORWARD -i eth0 ! -o eth0 -j DROP
-A FORWARD -o eth0 ! -i eth0 -m state ! --state UNTRACKED -j ACCEPT
COMMIT
EOF
ip6tables-nft-restore <<\EOF
*mangle
-A PREROUTING -i wg0 -p tcp -j TCPMSS --set-mss 1360
-A POSTROUTING -o wg0 -p tcp -j TCPMSS --set-mss 1360
COMMIT
*filter
:WEBSERVER -
:FORWARD DROP
-A FORWARD -i eth0 ! -o eth0 -d "2602:806:a000:2a88:0:100:0:1" -j WEBSERVER
-A WEBSERVER -p tcp -m multiport --dports 53,80,443 -j ACCEPT
-A WEBSERVER -p udp -m multiport --dports 53 -j ACCEPT
-A FORWARD -i eth0 ! -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
-A FORWARD -i eth0 ! -o eth0 -j DROP
-A FORWARD -o eth0 ! -i eth0 -m state ! --state UNTRACKED -j ACCEPT
COMMIT
EOF
sysctl -w "net.ipv4.ip_forward=1" "net.ipv6.conf.all.forwarding=1"
ip link add wg0 type wireguard
wg setconf wg0 /__autoserver-local__/local/wg0-vm16.conf
wg addconf wg0 /__autoserver-local__/local/wg0-vm16-peers.conf
ip addr add "100.78.0.1/18" dev wg0
ip addr add "2602:806:a000:2a00::1/55" dev wg0
ip link set wg0 up
fi'
