#!/bin/sh
set -eu
REPO_ROOT="/home/henrie/gitprojects"
"$REPO_ROOT/ctrtool-containers/misc/vrf-setup" vpnvrf0 10 # local_setup
"$REPO_ROOT/ctrtool-containers/misc/vrf-setup" vpnvrf1 11
"$REPO_ROOT/ctrtool-containers/misc/vrf-setup" vpnvrf2 12
"$REPO_ROOT/ctrtool-containers/misc/vrf-setup" vpnvrf3 13
"$REPO_ROOT/ctrtool-containers/misc/vrf-setup" vpnvrf4 14
"$REPO_ROOT/ctrtool-containers/wireguard-netns-bridge/wg-netns-bridge" local_if=to_vpn_0 wg_if=wg0 netns=vpn_0 wg_addresses='192.168.0.2 2001:db8:0:100::2' lan_addresses='192.168.10.1/24 2001:db8:0:110::1/64' wg_conf="$REPO_ROOT/ctrtool-config_tars/u-relay-portable/setup/wg0.conf" wg_unreach='192.168.10.0/23 2001:db8:0:110::/60'
# sh -x
"$REPO_ROOT/ctrtool-containers/misc/nns2vrf" vrf=vpnvrf0 netns=/run/netns/vpn_0 routes_ipv4='192.168.11.0/30' routes_ipv6='2001:db8:0:111::/64' local_addr='192.168.11.1 2001:db8:0:111::1' foreign_addr='0.0.0.10' local_if=vpn0 foreign_if=to_main_vrf
"$REPO_ROOT/ctrtool-containers/wireguard-netns-bridge/wg-netns-bridge" local_if=to_vpn_1 wg_if=wg1 netns=vpn_1 wg_addresses='192.168.0.2 2001:db8:0:100::2' lan_addresses='192.168.10.1/24 2001:db8:0:110::1/64' wg_conf="$REPO_ROOT/ctrtool-config_tars/u-relay-portable/setup/wg1.conf" wg_unreach='192.168.10.0/23 2001:db8:0:110::/60'
"$REPO_ROOT/ctrtool-containers/misc/nns2vrf" vrf=vpnvrf1 netns=/run/netns/vpn_1 routes_ipv4='192.168.11.0/30' routes_ipv6='2001:db8:0:111::/64' local_addr='192.168.11.1 2001:db8:0:111::1' foreign_addr='0.0.0.10' local_if=vpn1 foreign_if=to_main_vrf
"$REPO_ROOT/ctrtool-config_tars/u-relay-portable/setup/setup_u-relay-main.sh"
nsenter --net='/run/netns/u-relay-main' "$REPO_ROOT/ctrtool-containers/misc/netns-tool" mode=l3_system local_if=to_dist netns=u-relay-dist routes_err='fedb:1200:4500:7810::/60' address='fedb:1200:4500:7810::1'
nsenter --net=/run/netns/u-relay-dist "$REPO_ROOT/ctrtool-config_tars/u-relay-portable/setup/dist2access.sh" br1 'fedb:1200:4500:7811::1/64'
nsenter --net=/run/netns/vpn_0 wg set wg0 private-key "$WG_PRIVATE/wg0-pk.txt"
nsenter --net=/run/netns/vpn_1 wg set wg1 private-key "$WG_PRIVATE/wg1-pk.txt"
