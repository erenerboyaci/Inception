FILE = -f srcs/docker-compose.yml
COMPOSE = docker compose


up:
	$(COMPOSE) $(FILE) up -d

build:
	$(COMPOSE) $(FILE) build

down:
	$(COMPOSE) $(FILE) down

restart: down up

clean:
	$(COMPOSE) $(FILE) down -v --remove-orphans

fclean: clean
	docker system prune -af

certs:
	mkdir -p ./secrets/certs
	openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048\
    -keyout ./secrets/certs/server.key\
    -out ./secrets/certs/server.crt\
    -subj "/CN=localhost"

.PHONY: up build down restart clean fclean certs