# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

**Nami** is an Nginx reverse proxy gateway for the `happykiller.net` domain family, managed via Docker Compose. It handles SSL termination, CORS, rate limiting, and proxying to backend services running on the same Docker network.

## Common commands

```bash
make start          # Start containers (no rebuild)
make startall       # Rebuild images and start
make reload-nami    # Restart only the nginx container — use after changing nginx.conf or certs
make down           # Stop containers
make reset          # Full teardown: stop, remove containers and volumes
make renew          # Renew all Let's Encrypt certificates
make cert DOMAIN=sub.happykiller.net  # Issue a new cert for a subdomain, then reloads nginx
```

After any change to `nginx.conf` or `cors.conf`, run `make reload-nami` — no rebuild needed.

## Architecture

### Networking
- All backend services must be on the external Docker network `interservices`. Nami joins this network, which allows it to resolve containers by name (e.g., `lilith_front`, `gold_back`).
- `host.docker.internal` is mapped to `host-gateway`, allowing proxying to services running directly on the host.

### Rate limiting zones (defined in `nginx.conf`)
- `ddos` zone — 5 req/s, used for frontend server blocks (`burst=10`)
- `bruteforce` zone — 50 req/s, used for API server blocks (`burst=100`)

### CORS (`cors.conf`)
CORS headers are applied via `include /etc/nginx/cors.conf` inside API `location` blocks. Only origins matching `*.happykiller.net` or `happykiller.net` are allowed. The file strips upstream CORS headers and replaces them with controlled values.

### SSL
Certificates live in `certbot/conf/` and are mounted read-only into the nginx container. The `certbot/www/` directory handles ACME `.well-known/acme-challenge/` responses over HTTP (port 80).

### Adding a new service
1. Add the subdomain to the `server_name` list in the HTTP port-80 block.
2. Define an `upstream` block pointing to the container name and port.
3. Add an HTTPS `server` block with the appropriate cert paths and `proxy_pass`.
4. Issue a cert: `make cert DOMAIN=new.happykiller.net`
5. Apply: `make reload-nami`

API endpoints should use the `bruteforce` rate limit zone and `include /etc/nginx/cors.conf`. Frontend endpoints use the `ddos` zone.
