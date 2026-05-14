# Scripts Directory

This directory contains utility scripts for managing the nami nginx reverse proxy.

## renew-certificates.sh

**Automated SSL certificate renewal script for all domains.**

### Usage

```bash
./scripts/renew-certificates.sh
```

### What it does

- Iterates through all 15 happykiller.net domains
- Renews certificates using `docker compose` and `certbot`
- Handles the process robustly (won't stop on individual errors)
- Show progress [Current/Total]
- Provides a summary of success and failures at the end

### Domains covered

- happykiller.net
- www.happykiller.net
- wiki.happykiller.net
- york.happykiller.net
- stella.happykiller.net
- lilith.happykiller.net
- api.lilith.happykiller.net
- gold.happykiller.net
- api.gold.happykiller.net
- vergo.happykiller.net
- api.vergo.happykiller.net
- siguri.happykiller.net
- api.siguri.happykiller.net
- kalifa.happykiller.net
- puppet.happykiller.net

### After renewal

After successful renewal, reload nginx to apply the new certificates:

```bash
docker compose exec nami nginx -s reload
```

### Automation

Example crontab entry (runs on the 1st of every month at 3 AM):

```cron
0 3 1 * * cd /home/admin/nami && ./scripts/renew-certificates.sh >> /var/log/certbot-renewal.log 2>&1 && docker compose exec nami nginx -s reload
```
