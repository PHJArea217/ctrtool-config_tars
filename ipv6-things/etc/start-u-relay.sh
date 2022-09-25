#!/bin/sh

set -eu
cd /etc/node_app

exec /ctr_fs1/_system/bin/ctrtool ns_open_file -o 5 \
	-n -6 ::,443,a -l4096 \
	-n -6 ::,80,a -l4096 \
	-n -d inet -4 127.0.0.10,81,a -l4096 \
	setpriv --reuid=u-relay --regid=u-relay --clear-groups \
	env NODE_PATH=/ctr_fs2/node_js/usr/local/lib/node_modules \
	/ctr_fs2/node_js/usr/local/bin/node entrypoint.js
