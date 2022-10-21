#!/bin/sh
set -eu
REPO_ROOT="/home/henrie/gitprojects"
"$REPO_ROOT/ctrtool-containers/2layer/make-2layer.py" /dev/null "$1" "0.$2.200" "0.$2.200" "$2" "$2" flags netns_ambient snippets mix_mounts,extract_config_tar netns_veth_name to_urelay ctrtool "$REPO_ROOT/container-scripts/ctrtool/ctrtool"
cp -r "$REPO_ROOT/ctrtool-config_tars/u-relay-portable/etc/." "$1/config_dir"
mkdir -p "$1/config_dir/node_app"
cp -r "$REPO_ROOT/universal-relay" "$1/config_dir/node_app/universal-relay"
"$1/make_config_tar.sh"
exit 0




nsenter --net=/run/netns/u-relay-main sh -eu -c '
# ip link add X type veth peer name Y netns Z
ip addr add "fedb:1200:4500:7802::1" dev "to_urelay"
ip link set dev "to_urelay" address 00:00:5e:00:53:42 up
ip route add "fedb:1200:4500:7800::/63" via inet6 fe80::200:5eff:fe00:5343 dev "to_urelay"
'
