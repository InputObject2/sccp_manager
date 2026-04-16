# SIPIS Deploy Bundle

Files:
- `install_sipis.sh` - Debian 11/12 installer.
- `.env.example` - secrets template.
- `docker-compose.yml.template` - compose template from official Acrobits images.
- `templates/Settings.xml.template` - SIPIS XML template.

Usage:
```bash
chmod +x install_sipis.sh
DOMAIN=sipis.example.com LETSENCRYPT_EMAIL=admin@example.com ADMIN_IPS="1.2.3.4/32" ./install_sipis.sh
```

Note:
- For private Acrobits registry access use `docker login docker.acrobits.net`.
- Do not commit generated `.env`, real `Settings.xml`, database dumps, cert private keys.
