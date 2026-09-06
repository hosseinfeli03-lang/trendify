#!/bin/bash
set -e

echo "======================================"
echo " Starting 3X-UI on Railway"
echo "======================================"

mkdir -p /data/x-ui
chmod 700 /data/x-ui

PORT="${PORT:-8080}"

echo "Port: ${PORT}"
echo "Database: /data/x-ui"

cd /usr/local/x-ui

echo "Configuring panel..."

./x-ui setting -port "$PORT" || true
./x-ui setting -listenIP "0.0.0.0" || true

echo "Starting 3X-UI..."

./x-ui &
XUI_PID=$!

echo "Starting SSH..."

/usr/sbin/sshd -D -e &
SSH_PID=$!

trap 'kill $XUI_PID $SSH_PID 2>/dev/null || true' TERM INT

wait $XUI_PID
