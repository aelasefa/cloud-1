#!/bin/sh
set -e

# Validate required variables
if [ -z "$REDIS_PASSWORD" ]; then
	echo "[ERROR] REDIS_PASSWORD is required but not set." >&2
	exit 1
fi

# Redis startup script with environment variable support
exec redis-server \
	--dir /data \
	--bind 0.0.0.0 \
	--port "${REDIS_PORT:-6379}" \
	--requirepass "${REDIS_PASSWORD}" \
	--save 900 1 \
	--save 300 10 \
	--save 60 10000 \
	--appendonly yes \
	--appendfsync everysec \
	--maxmemory 256mb \
	--maxmemory-policy allkeys-lru \
	--loglevel notice
