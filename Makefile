FILE = -f srcs/docker-compose.yml
COMPOSE = docker compose


up: dirs
	$(COMPOSE) $(FILE) up -d

dirs:
	mkdir -p /home/merboyac/data/mysql
	mkdir -p /home/merboyac/data/wordpress

build:
	$(COMPOSE) $(FILE) build

down:
	$(COMPOSE) $(FILE) down

restart: down up

clean:
	$(COMPOSE) $(FILE) down -v --remove-orphans

fclean:
	$(COMPOSE) $(FILE) down -v --rmi all --remove-orphans
	docker system prune -af
	sudo rm -rf /home/merboyac/data/
	rm -f ../secrets/db_password.txt ../secrets/db_root_password.txt
	rm -rf ./secrets/certs

logs:
	$(COMPOSE) $(FILE) logs -f




.PHONY: dirs up build down restart clean fclean logs
