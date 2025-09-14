FILE = -f srcs/docker-compose.yml
COMPOSE = docker compose


up: dirs
	$(COMPOSE) $(FILE) up -d

dirs:
	mkdir -p /home/merboyac/data/mysql
	mkdir -p /home/merboyac/data/wordpress

build:
	$(COMPOSE) $(FILE) --build

down:
	$(COMPOSE) $(FILE) down

restart: down up

clean:
	$(COMPOSE) $(FILE) down -v --remove-orphans

fclean: clean
	$(COMPOSE) $(FILE) down -v --rmi all --remove-orphans
	docker system prune -af
	sudo rm -rf /home/merboyac/data/mysql
	sudo rm -rf /home/merboyac/data/wordpress
	rm -f ../secrets/db_password.txt ../secrets/db_root_password.txt
	rm -rf ./secrets/certs
	sudo rm -rf /home/merboyac/data/mysql
	sudo rm -rf /home/merboyac/data/wordpress

certs:
	mkdir -p ./secrets/certs
	openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048\
    -keyout ./secrets/certs/server.key\
    -out ./secrets/certs/server.crt\
    -subj "/CN=localhost"

.PHONY: dirs up build down restart clean fclean certs