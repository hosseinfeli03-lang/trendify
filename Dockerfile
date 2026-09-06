FROM ghcr.io/mhsanaei/3x-ui:v3.7.0

ENV XUI_DB_TYPE=sqlite
ENV XUI_DB_FOLDER=/data/x-ui
ENV XUI_ENABLE_FAIL2BAN=false
ENV XRAY_VMESS_AEAD_FORCED=false
ENV XUI_INIT_WEB_BASE_PATH=/

RUN mkdir -p /data/x-ui /run/sshd /root/.ssh

COPY start-railway.sh /usr/local/bin/start-railway.sh

RUN chmod +x /usr/local/bin/start-railway.sh

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/start-railway.sh"]
