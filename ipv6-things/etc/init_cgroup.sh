#!/bin/sh
set -eu
mount -t cgroup2 none /sys/fs/cgroup
mkdir /sys/fs/cgroup/init.scope
echo '1' > /sys/fs/cgroup/init.scope/cgroup.procs
echo "$$" > /sys/fs/cgroup/init.scope/cgroup.procs
echo '+memory +pids' > /sys/fs/cgroup/cgroup.subtree_control
