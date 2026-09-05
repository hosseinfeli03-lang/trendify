FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

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
    systemd && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/sshd

RUN useradd -m -s /bin/bash admin && \
    echo "admin:ChangeMe123!" | chpasswd && \
    usermod -aG sudo admin

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
