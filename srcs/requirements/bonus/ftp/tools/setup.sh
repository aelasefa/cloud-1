#!/bin/bash
set -e

# Validate required variables
: "${FTP_USER:?FTP_USER must be set}"
FTP_PASSWORD="${FTP_PASSWORD:-$FTP_PASS}"
: "${FTP_PASSWORD:?FTP_PASSWORD must be set}"
FTP_ROOT="${FTP_ROOT:-/var/www/html}"

echo "[*] Setting up FTP Server..."

# Create www-data group if it doesn't exist
groupadd -g 33 www-data 2>/dev/null || true

# Create FTP user if it doesn't exist
if ! id "$FTP_USER" &>/dev/null; then
	echo "[*] Creating FTP user: $FTP_USER"
	useradd -m -d "$FTP_ROOT" -s /bin/bash -g 33 "$FTP_USER" 2>/dev/null || true
fi

# Set FTP user password
echo "[*] Setting password for FTP user..."
echo "$FTP_USER:$FTP_PASSWORD" | chpasswd

# Create authorized user list
echo "[*] Creating vsftpd userlist..."
mkdir -p /etc/vsftpd
echo "$FTP_USER" > /etc/vsftpd/userlist

# Ensure proper permissions
chmod 600 /etc/vsftpd/userlist
chmod 600 /etc/vsftpd/vsftpd.conf

# Create WordPress data directory if needed
if [ ! -d "$FTP_ROOT" ]; then
	echo "[*] Creating WordPress root directory: $FTP_ROOT"
	mkdir -p "$FTP_ROOT"
fi

# Set correct permissions on WordPress directory
chown -R "$FTP_USER":"$FTP_USER" "$FTP_ROOT" 2>/dev/null || true
chmod -R 775 "$FTP_ROOT" 2>/dev/null || true

echo "[*] FTP Server setup completed successfully!"
echo "[*] FTP User: $FTP_USER"
echo "[*] FTP Root: $FTP_ROOT"
echo "[*] Starting vsftpd..."

exec "$@"
