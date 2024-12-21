# Makefile
# Mark targets as not file-dependent; they are always executed
.PHONY: reload-nami start startall down reset help

# Start the containers defined in docker-compose.yml without rebuilding images
start: 
	docker compose up -d

# Rebuild the images before starting the containers
startall: 
	docker compose up --build -d

# Restart only the nami container to apply configuration changes
reload-nami:
	docker compose stop nami
	docker compose rm -f nami
	docker compose up -d nami

# Stop the nami and certbot containers
down:
	docker stop nami certbot

# Stop and completely remove the nami and certbot containers, including volumes
reset: down
	docker rm nami certbot
	docker volume prune -f

# Display user help for available commands
help:
	@echo "" 
	@echo "~~ Nami Makefile ~~"
	@echo ""
	@echo "\033[33m make start\033[39m    : Start the project"
	@echo "\033[33m make startall\033[39m : Build and start the project"
	@echo "\033[33m make reload-nami\033[39m : Restart nami to apply changes (nginx.conf, certificates, etc.)"
	@echo "\033[33m make down\033[39m     : Stop the project"
	@echo "\033[33m make reset\033[39m    : Reset containers, volumes, networks, and local data"
	@echo "\033[33m make reload-nami\033[39m : Restart nami to apply changes (nginx.conf, certificates, etc.)"
	@echo ""
