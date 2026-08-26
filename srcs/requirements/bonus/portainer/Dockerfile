FROM alpine:3.18

LABEL version="1.0" description="Portainer Container Management Interface"


RUN apk add --no-cache wget ca-certificates


RUN wget -q https://github.com/portainer/portainer/releases/download/2.19.4/portainer-2.19.4-linux-amd64.tar.gz \
    && tar -xzf portainer-2.19.4-linux-amd64.tar.gz -C /opt \
    && rm portainer-2.19.4-linux-amd64.tar.gz \
    && mkdir -p /data


EXPOSE 9000


HEALTHCHECK --interval=10s --timeout=5s --retries=5 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:9000 2>/dev/null || exit 1


ENTRYPOINT ["/opt/portainer/portainer"]

