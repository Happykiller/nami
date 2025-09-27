#!/usr/bin/env bash
set -euo pipefail

# Petit log pour debug
echo "[$(date -Is)] Deploy hook: reload nginx in 'nami' container"

# Recharge nginx dans le container (sans TTY)
docker compose exec -T nami nginx -s reload || {
  echo "[$(date -Is)] WARN: nginx reload failed"; exit 1;
}
