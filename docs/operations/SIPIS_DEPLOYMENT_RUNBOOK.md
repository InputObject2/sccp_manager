# SIPIS Deployment Runbook (Debian + Docker)

## Purpose
This runbook deploys Acrobits SIPIS in a reproducible way, without storing secrets in git.

## Container Source
- Vendor docs (archived): https://web.archive.org/web/20250816105542/https://doc.acrobits.net/sipis/docker.html
- Vendor registry: `docker.acrobits.net/releases/*`
- Required images:
  - `docker.acrobits.net/releases/sipis:latest`
  - `docker.acrobits.net/releases/dbsipis:latest`
  - `docker.acrobits.net/releases/lb2:latest`
  - `docker.acrobits.net/releases/stunnelsipis:latest`

If pull fails with auth error, run:
```bash
docker login docker.acrobits.net
```

## What is in this repo
- `docs/operations/sipis-deploy/install_sipis.sh` - full install script for Debian 11/12.
- `docs/operations/sipis-deploy/.env.example` - env template (no secrets).
- `docs/operations/sipis-deploy/docker-compose.yml.template` - compose template.
- `docs/operations/sipis-deploy/templates/Settings.xml.template` - SIPIS settings template.

## Quick Install (new host)
1. Copy deploy folder to host (`/opt/sipis` target path is used by script).
2. Run installer with required env vars:
```bash
chmod +x ./docs/operations/sipis-deploy/install_sipis.sh
DOMAIN=sipis.example.com \
LETSENCRYPT_EMAIL=admin@example.com \
ADMIN_IPS="1.2.3.4/32,5.6.7.8/32" \
./docs/operations/sipis-deploy/install_sipis.sh
```
3. If registry credentials are required:
```bash
docker login docker.acrobits.net
cd /opt/sipis
docker compose pull && docker compose up -d
```

## Installed Components and Ports
- `stunnelsipis`:
  - `443/tcp` (public HTTPS front-end for SIPIS stats/api)
- `lb2`:
  - `24998/tcp` (SIPIS signaling path)
  - `4998/tcp`, `4998/udp` (push/media relay path used by Acrobits stack)
- `sipis`:
  - `5000/tcp` bound to localhost only (`127.0.0.1`)
- `dbsipis`:
  - internal PostgreSQL only

## Firewall Baseline
Installer configures:
- default deny inbound
- `22/tcp` allowed only from `ADMIN_IPS`
- `443/tcp` allowed only from `ADMIN_IPS`
- `24998/tcp`, `4998/tcp`, `4998/udp` public
- `5000/tcp` blocked externally

If you use container egress restrictions (`DOCKER-USER` with final DROP), explicitly allow:
- DNS `53/tcp,53/udp`
- outbound `5060/tcp,5061/tcp` to PBX IPs
- outbound `6552/tcp` (PNM cloud endpoint)

## DNS Requirements
Required records:
- `A sipis.example.com -> <public_ip>`
- `_sips._tcp.<domain> SRV 0 0 5061 <pbx-host>`
- optional compatibility records:
  - `_sip._tls.<domain> SRV 0 0 5061 <pbx-host>`
  - `_sips._tls.<domain> SRV 0 0 5061 <pbx-host>`

## Health Checks
```bash
docker ps
curl -k --digest -u admin:<password> https://127.0.0.1/stats
docker logs --tail 200 sipis
```

PBX side (Asterisk):
```bash
asterisk -rx "pjsip show contacts"
```
SIPIS contacts should be `Avail`.

## Upgrade Procedure
```bash
cd /opt/sipis
docker compose pull
docker compose up -d
```

## Backup / Restore
Backup:
```bash
tar czf /root/sipis-config-$(date +%F).tgz /opt/sipis/config /opt/sipis/docker-compose.yml /opt/sipis/.env
```
Restore:
- extract backup to `/`
- verify certs in `/opt/sipis/certs`
- `cd /opt/sipis && docker compose up -d`

## Security Notes
- Do not commit `.env`, `Settings.xml`, DB dumps, tokens, cert private keys.
- Keep admin `/stats` behind source IP restriction.
- Keep GeoIP optional; first stabilize push path, then re-enable with explicit exceptions.
