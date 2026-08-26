COMPOSE = docker compose -f srcs/docker-compose.yml --env-file srcs/.env
DOMAIN = $(shell grep -E '^DOMAIN_NAME=' srcs/.env | cut -d= -f2)
DATA_PATH = $(shell grep -E '^DATA_PATH=' srcs/.env | cut -d= -f2)
DATA_DIR = $(if $(DATA_PATH),$(DATA_PATH),$(HOME)/data)
WP_ADMIN_USER = $(shell grep -E '^WP_ADMIN_USER=' srcs/.env | cut -d= -f2)
WP_ADMIN_PASS = $(shell grep -E '^WP_ADMIN_PASS=' srcs/.env | cut -d= -f2)

.PHONY: all prepare build up down restart ps logs clean fclean re hosts cert-install bonus

all: prepare build up

prepare:
	@echo "Preparing host data directories at $(DATA_DIR)"
	@mkdir -p $(DATA_DIR)/mariadb \
	         $(DATA_DIR)/wordpress \
	         $(DATA_DIR)/redis \
	         $(DATA_DIR)/ftp \
	         $(DATA_DIR)/portainer
	@echo "Setting correct ownership per service"
	@sudo chown -R 999:999 $(DATA_DIR)/mariadb 2>/dev/null || true
	@sudo chown -R 100:101 $(DATA_DIR)/redis 2>/dev/null || true
	@sudo chown -R 1000:1000 $(DATA_DIR)/ftp 2>/dev/null || true
	@sudo chown -R $(shell id -u):$(shell id -g) $(DATA_DIR)/wordpress 2>/dev/null || true
	@sudo chown -R $(shell id -u):$(shell id -g) $(DATA_DIR)/portainer 2>/dev/null || true

build:
	@echo "Building images"
	$(COMPOSE) build

up:
	@echo "Starting stack"
	$(COMPOSE) up -d --build

down:
	@echo "Stopping stack"
	$(COMPOSE) down

ps:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs --tail=200 -f

clean: down
	-@docker volume rm srcs_wordpress_data srcs_mariadb_data srcs_redis_data srcs_portainer_data 2>/dev/null || true

fclean: clean
	-@docker rmi $$(docker images 'srcs-*' -q) 2>/dev/null || true

re: fclean all

hosts:
	@echo "Adding $(DOMAIN) to /etc/hosts (requires sudo)"
	@grep -q "$(DOMAIN)" /etc/hosts 2>/dev/null || sudo sh -c 'printf "127.0.0.1 $(DOMAIN)\n" >> /etc/hosts'

# Copy nginx cert from container and install to system (requires sudo)
cert-install:
	@echo "Copying cert from nginx container to /tmp/$(DOMAIN).crt"
	@docker cp nginx:/etc/ssl/certs/server.crt /tmp/$(DOMAIN).crt || (echo "failed to copy cert"; exit 1)
	@echo "Installing certificate to system trust store (requires sudo)"
	@sudo cp /tmp/$(DOMAIN).crt /usr/local/share/ca-certificates/$(DOMAIN).crt && sudo update-ca-certificates || (echo "failed to install cert"; exit 1)

bonus:
	@echo "Running bonus smoke tests..."
	$(COMPOSE) up -d --build
	@sleep 3
	@echo "-- Services --"
	$(COMPOSE) ps
	@echo "-- Home (first 10 lines) --"
	@curl -ksS --resolve $(DOMAIN):443:127.0.0.1 https://$(DOMAIN)/ | sed -n '1,10p' || true
	@echo "-- WP Login (first 20 lines) --"
	@curl -ksS --resolve $(DOMAIN):443:127.0.0.1 https://$(DOMAIN)/wp-login.php | sed -n '1,20p' || true
	@echo "-- Attempt login (cookies saved to /tmp/cookies) --"
	@/usr/bin/curl -ksS --resolve $(DOMAIN):443:127.0.0.1 -c /tmp/cookies -d "log=$(WP_ADMIN_USER)&pwd=$(WP_ADMIN_PASS)&wp-submit=Log+In&redirect_to=https://$(DOMAIN)/wp-admin/&testcookie=1" -i -L https://$(DOMAIN)/wp-login.php | sed -n '1,40p' || true
	@echo "-- WP Admin (first 20 lines) --"
	@/usr/bin/curl -ksS --resolve $(DOMAIN):443:127.0.0.1 -b /tmp/cookies https://$(DOMAIN)/wp-admin/ | sed -n '1,20p' || true
	@echo "-- Volumes --"
	@docker volume ls | grep srcs_ || true
	@echo "Bonus smoke tests completed."
