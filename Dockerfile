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
    ca-certificates \
    tar \
    procps \
    iproute2 \
    net-tools \
    nano \
    vim \
    nginx \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/sshd /root/.ssh /data/x-ui

RUN cd /tmp && \
    wget -q https://github.com/MHSanaei/3x-ui/releases/download/v3.7.0/x-ui-linux-amd64.tar.gz && \
    tar -xzf x-ui-linux-amd64.tar.gz && \
    mv x-ui /usr/local/x-ui && \
    chmod +x /usr/local/x-ui/x-ui && \
    chmod +x /usr/local/x-ui/bin/xray-linux-amd64 && \
    rm -f /tmp/x-ui-linux-amd64.tar.gz

COPY railway.conf /etc/nginx/conf.d/railway.conf
COPY start-railway.sh /usr/local/bin/start-railway.sh

RUN chmod +x /usr/local/bin/start-railway.sh

EXPOSE 22
EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/start-railway.sh"]
