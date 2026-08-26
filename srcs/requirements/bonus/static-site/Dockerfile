FROM alpine:3.18

LABEL version="1.0" description="Static Website Server"

# Install Nginx
RUN apk add --no-cache nginx

# Create necessary directories and user
RUN mkdir -p /var/www/static /var/run/nginx && \
	addgroup -S nginx 2>/dev/null || true && \
	adduser -S -G nginx nginx 2>/dev/null || true

# Copy Nginx configuration
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Copy static website files
COPY www/ /var/www/static/

# Set permissions
RUN chown -R nginx:nginx /var/www/static && \
	chmod -R 755 /var/www/static && \
	chown -R nginx:nginx /var/run/nginx

# Expose port
EXPOSE 8081

# Health check
HEALTHCHECK --interval=10s --timeout=3s --retries=5 \
	CMD wget --quiet --tries=1 --spider http://localhost:8081/ || exit 1

# Run Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
