#!/bin/bash
# env-check.sh - Validate required environment variables
# Usage: ./env-check.sh [service]
# Services: all, mariadb, wordpress, nginx, redis, ftp, bonus

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SERVICE="${1:-all}"
ERRORS=0

check_var() {
    local var_name="$1"
    local var_value="${!var_name}"
    
    if [ -z "$var_value" ]; then
        echo -e "${RED}[ERROR]${NC} Missing required variable: $var_name"
        ERRORS=$((ERRORS + 1))
        return 1
    else
        echo -e "${GREEN}[OK]${NC} $var_name is set"
        return 0
    fi
}

check_file() {
    local file_path="$1"
    
    if [ ! -f "$file_path" ]; then
        echo -e "${RED}[ERROR]${NC} Missing required file: $file_path"
        ERRORS=$((ERRORS + 1))
        return 1
    else
        echo -e "${GREEN}[OK]${NC} File exists: $file_path"
        return 0
    fi
}

check_mariadb() {
    echo -e "${YELLOW}=== Checking MariaDB variables ===${NC}"
    check_var "MYSQL_DATABASE"
    check_var "MYSQL_USER"
    check_var "MYSQL_PASSWORD"
    check_var "MYSQL_ROOT_PASSWORD"
}

check_wordpress() {
    echo -e "${YELLOW}=== Checking WordPress variables ===${NC}"
    check_var "DOMAIN_NAME"
    check_var "WP_ADMIN_USER"
    check_var "WP_ADMIN_PASS"
    check_var "WP_ADMIN_EMAIL"
    check_var "WP_USER_USER"
    check_var "WP_USER_PASS"
    check_var "WP_USER_EMAIL"
}

check_nginx() {
    echo -e "${YELLOW}=== Checking Nginx variables ===${NC}"
    check_var "DOMAIN_NAME"
}

check_redis() {
    echo -e "${YELLOW}=== Checking Redis variables ===${NC}"
    check_var "REDIS_HOST"
    check_var "REDIS_PASSWORD"
}

check_ftp() {
    echo -e "${YELLOW}=== Checking FTP variables ===${NC}"
    check_var "FTP_USER"
    check_var "FTP_PASSWORD"
}

check_secrets() {
    echo -e "${YELLOW}=== Checking secret files ===${NC}"
    local SECRETS_DIR="${SECRETS_DIR:-./secrets}"
    check_file "$SECRETS_DIR/db_password.txt"
    check_file "$SECRETS_DIR/db_root_password.txt"
    check_file "$SECRETS_DIR/credentials.txt"
}

case "$SERVICE" in
    all)
        check_mariadb
        check_wordpress
        check_nginx
        check_redis
        check_ftp
        ;;
    mariadb)
        check_mariadb
        ;;
    wordpress)
        check_wordpress
        ;;
    nginx)
        check_nginx
        ;;
    redis)
        check_redis
        ;;
    ftp)
        check_ftp
        ;;
    bonus)
        check_redis
        check_ftp
        ;;
    secrets)
        check_secrets
        ;;
    *)
        echo "Unknown service: $SERVICE"
        echo "Usage: $0 [all|mariadb|wordpress|nginx|redis|ftp|bonus|secrets]"
        exit 1
        ;;
esac

echo ""
if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}Validation failed with $ERRORS error(s)${NC}"
    exit 1
else
    echo -e "${GREEN}All required variables are set${NC}"
    exit 0
fi
