#!/bin/sh
set -e

mkdir -p /data/x-ui

PORT="${PORT:-8080}"

echo "======================================"
echo " Starting 3X-UI on Railway"
echo " Port: ${PORT}"
echo " Database: /data/x-ui"
echo "======================================"

cd /usr/local/x-ui

/usr/local/x-ui/x-ui setting -port "$PORT" || true
/usr/local/x-ui/x-ui setting -listenIP "0.0.0.0" || true

exec /usr/local/x-ui/x-ui
