#!/bin/bash
set -e

echo "======================================"
echo " Starting 3X-UI on Railway"
echo "======================================"

mkdir -p /data/x-ui
chmod 700 /data/x-ui

# استفاده از دیتابیس موجود روی Railway Volume
if [ ! -f /data/x-ui/x-ui.db ]; then
    mkdir -p /etc/x-ui
fi

# اتصال مسیر دیتابیس 3X-UI به Railway Volume
rm -rf /etc/x-ui
ln -s /data/x-ui /etc/x-ui

PORT="${PORT:-8080}"

echo "Port: ${PORT}"
echo "Database: /data/x-ui"

cd /usr/local/x-ui

echo "Configuring panel port..."

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
