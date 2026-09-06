FROM ghcr.io/mhsanaei/3x-ui:v3.7.0

ENV XUI_DB_TYPE=sqlite
ENV XUI_DB_FOLDER=/data/x-ui
ENV XUI_ENABLE_FAIL2BAN=false
ENV XRAY_VMESS_AEAD_FORCED=false
ENV XUI_INIT_WEB_BASE_PATH=/

RUN apt-get update && \
    apt-get install -y openssh-server sudo curl wget nano vim procps iproute2 net-tools ca-certificates && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /run/sshd /root/.ssh

RUN cat > /usr/local/bin/start-railway.sh <<'EOF'
#!/bin/bash
set -e

mkdir -p /data/x-ui

# Keep Railway PORT as the 3X-UI web port
PORT="${PORT:-8080}"

echo "Starting 3X-UI on port ${PORT}"

# Configure panel
/usr/local/x-ui/x-ui setting -port "$PORT" || true
/usr/local/x-ui/x-ui setting -listenIP "0.0.0.0" || true

cd /usr/local/x-ui

# Start 3X-UI
./x-ui &
XUI_PID=$!

# Start SSH
/usr/sbin/sshd -D -e &
SSH_PID=$!

echo "3X-UI PID: ${XUI_PID}"
echo "SSH PID: ${SSH_PID}"

wait "$XUI_PID"
EOF

RUN chmod +x /usr/local/bin/start-railway.sh

EXPOSE 22
EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/start-railway.sh"]
