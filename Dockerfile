FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV XRAY_VMESS_AEAD_FORCED=false
ENV XUI_ENABLE_FAIL2BAN=false

RUN apt-get update && \
    apt-get install -y \
    openssh-server \
    sudo \
    curl \
    wget \
    git \
    nano \
    vim \
    ca-certificates \
    net-tools \
    iproute2 \
    iputils-ping \
    procps \
    tar \
    && rm -rf /var/lib/apt/lists/*

# SSH
RUN mkdir -p /run/sshd /root/.ssh

# Install 3X-UI v3.7.0
RUN cd /tmp && \
    wget -q https://github.com/MHSanaei/3x-ui/releases/download/v3.7.0/x-ui-linux-amd64.tar.gz && \
    tar -xzf x-ui-linux-amd64.tar.gz && \
    chmod +x x-ui/x-ui x-ui/bin/xray-linux-* x-ui/x-ui.sh && \
    rm -rf /usr/local/x-ui /usr/bin/x-ui && \
    mv x-ui /usr/local/x-ui && \
    cp /usr/local/x-ui/x-ui.sh /usr/bin/x-ui && \
    rm -f /tmp/x-ui-linux-amd64.tar.gz

# Startup script
RUN cat > /usr/local/bin/start.sh <<'EOF'
#!/bin/bash
set -e

echo "======================================"
echo " Starting Railway 3X-UI container"
echo "======================================"

# Railway persistent volume
mkdir -p /data/x-ui

# First boot: move existing database/config to persistent volume
if [ ! -f /data/x-ui/x-ui.db ] && [ -f /etc/x-ui/x-ui.db ]; then
    echo "Copying existing x-ui database to /data..."
    cp -a /etc/x-ui/. /data/x-ui/
fi

# Keep the path expected by 3X-UI
rm -rf /etc/x-ui
ln -s /data/x-ui /etc/x-ui

mkdir -p /etc/x-ui

# Railway gives the HTTP port through $PORT
if [ -n "$PORT" ]; then
    echo "Setting 3X-UI panel port to Railway PORT=$PORT"
    /usr/local/x-ui/x-ui setting -port "$PORT" || true
fi

# Disable Fail2ban in container environment
export XRAY_VMESS_AEAD_FORCED=false
export XUI_ENABLE_FAIL2BAN=false

cd /usr/local/x-ui

echo "Starting 3X-UI..."
./x-ui &
XUI_PID=$!

sleep 3

echo "3X-UI PID: $XUI_PID"

echo "Starting SSH..."
/usr/sbin/sshd -D -e &
SSH_PID=$!

echo "SSH PID: $SSH_PID"

wait -n "$XUI_PID" "$SSH_PID"

echo "A main process exited."
exit 1
EOF

RUN chmod +x /usr/local/bin/start.sh

# Railway HTTP panel + SSH
EXPOSE 22
EXPOSE 2053

ENTRYPOINT ["/usr/local/bin/start.sh"]
