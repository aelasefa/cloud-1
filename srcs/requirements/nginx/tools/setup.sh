#!/bin/bash
set -e

: "${DOMAIN_NAME:?DOMAIN_NAME must be set}"

mkdir -p /etc/ssl/private /etc/ssl/certs

# Generate self-signed SSL certificate for the configured DOMAIN_NAME
if [ ! -f /etc/ssl/certs/server.crt ] || [ ! -f /etc/ssl/private/server.key ]; then
    echo "Generating SSL certificate for ${DOMAIN_NAME}..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/ssl/private/server.key \
        -out /etc/ssl/certs/server.crt \
        -subj "/CN=${DOMAIN_NAME}"
fi

# Substitute domain name placeholder into Nginx configuration
sed -i "s/DOMAIN_NAME_PLACEHOLDER/${DOMAIN_NAME}/g" /etc/nginx/nginx.conf

echo "Starting Nginx for ${DOMAIN_NAME}..."
exec "$@"
