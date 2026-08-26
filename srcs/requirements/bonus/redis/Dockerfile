FROM alpine:3.18

LABEL version="1.0" description="Redis Cache Server for WordPress"

RUN apk add --no-cache redis && \
	addgroup -S redis 2>/dev/null || true && \
	adduser -S -G redis redis 2>/dev/null || true


RUN mkdir -p /etc/redis /var/lib/redis /data && \
	chown -R redis:redis /var/lib/redis /data


EXPOSE 6379


COPY tools/start.sh /start.sh
RUN chmod +x /start.sh


HEALTHCHECK --interval=10s --timeout=3s --retries=5 \
	CMD redis-cli -h 127.0.0.1 ping 2>/dev/null | grep -q PONG || exit 1

USER redis

ENTRYPOINT ["/start.sh"]
