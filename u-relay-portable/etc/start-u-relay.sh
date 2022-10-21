#!/bin/sh

set -eu
cd /etc/node_app

exec /ctr_fs1/_system/bin/ctrtool ns_open_file -o10 \
	-n -d inet -4 127.0.0.10,81,a -l4096 \
	-n -6 ::1,82,at -l4096 \
	-n -6 fedb:1200:4500:7801::1,82,a -l4096 \
	setpriv --reuid=u-relay --regid=u-relay --clear-groups \
	env NODE_PATH=/ctr_fs2/node_js/usr/local/lib/node_modules \
	LD_PRELOAD=/etc/socket-enhancer \
	/ctr_fs2/node_js/usr/local/bin/node universal-relay/example.js
