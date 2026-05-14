#!/bin/bash

# Script to renew SSL certificates for all happykiller.net domains
# This script uses docker compose and certbot to renew certificates

# Prevent the script from exiting on error, handle errors manually
set +e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Trap Ctrl+C (INT) and exit
trap "echo -e '${RED}Script interrupted by user.${NC}'; exit 1" INT

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Change to project directory
cd "$PROJECT_DIR"

echo -e "${GREEN}=== SSL Certificate Renewal Script ===${NC}"
echo -e "${YELLOW}Project directory: $PROJECT_DIR${NC}"
echo ""

# List of all domains to renew
DOMAINS=(
    "happykiller.net"
    "www.happykiller.net"
    "wiki.happykiller.net"
    "york.happykiller.net"
    "stella.happykiller.net"
    "lilith.happykiller.net"
    "api.lilith.happykiller.net"
    "gold.happykiller.net"
    "api.gold.happykiller.net"
    "vergo.happykiller.net"
    "api.vergo.happykiller.net"
    "siguri.happykiller.net"
    "api.siguri.happykiller.net"
    "kalifa.happykiller.net"
    "puppet.happykiller.net"
)

# Counter for success/failure
SUCCESS_COUNT=0
FAILURE_COUNT=0
FAILED_DOMAINS=()
TOTAL_DOMAINS=${#DOMAINS[@]}
CURRENT=0

echo -e "${GREEN}Starting certificate renewal for $TOTAL_DOMAINS domains...${NC}"
echo ""

# Loop through each domain and renew certificate
for DOMAIN in "${DOMAINS[@]}"; do
    ((CURRENT++))
    echo -e "${BLUE}[$CURRENT/$TOTAL_DOMAINS]${NC} ${YELLOW}Processing: $DOMAIN${NC}"
    
    # We use -T to disable TTY allocation which causes "input device is not a TTY" errors
    # and < /dev/null to prevent stdin consumption
    docker compose run --rm -T certbot certonly \
        --webroot \
        --webroot-path /var/www/certbot/ \
        -d "$DOMAIN" \
        --expand \
        --non-interactive \
        --agree-tos \
        --email admin@happykiller.net < /dev/null
    
    EXIT_CODE=$?
    
    if [ $EXIT_CODE -eq 0 ]; then
        echo -e "${GREEN}✓ Successfully renewed certificate for $DOMAIN${NC}"
        ((SUCCESS_COUNT++))
    else
        echo -e "${RED}✗ Failed to renew certificate for $DOMAIN (Exit code: $EXIT_CODE)${NC}"
        ((FAILURE_COUNT++))
        FAILED_DOMAINS+=("$DOMAIN")
    fi
    
    echo "---------------------------------------------------"
    echo ""
done

# Print summary
echo -e "${GREEN}=== Renewal Summary ===${NC}"
echo -e "Total domains: $TOTAL_DOMAINS"
echo -e "${GREEN}Successful: $SUCCESS_COUNT${NC}"
echo -e "${RED}Failed: $FAILURE_COUNT${NC}"

if [ $FAILURE_COUNT -gt 0 ]; then
    echo ""
    echo -e "${RED}Failed domains:${NC}"
    for FAILED_DOMAIN in "${FAILED_DOMAINS[@]}"; do
        echo -e "  - $FAILED_DOMAIN"
    done
fi

echo ""
echo -e "${YELLOW}Note: After renewal, you may need to reload nginx:${NC}"
echo -e "  docker compose exec nami nginx -s reload"
echo ""

exit $FAILURE_COUNT
