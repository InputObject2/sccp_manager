#!/usr/bin/env bash
set -euo pipefail

# SIPIS installer for Debian 11/12.
# Installs dependencies, prepares directories and templates, configures firewall,
# pulls official Acrobits images, then starts the stack.

if [[ ${EUID} -ne 0 ]]; then
  echo "Run as root" >&2
  exit 1
fi

DEPLOY_DIR=${DEPLOY_DIR:-/opt/sipis}
ENV_FILE=${ENV_FILE:-${DEPLOY_DIR}/.env}
DOMAIN=${DOMAIN:-}
ADMIN_IPS=${ADMIN_IPS:-}
LETSENCRYPT_EMAIL=${LETSENCRYPT_EMAIL:-}

if [[ -z "${DOMAIN}" ]]; then
  echo "Set DOMAIN env var, example: DOMAIN=sipis.example.com" >&2
  exit 1
fi

if [[ -z "${LETSENCRYPT_EMAIL}" ]]; then
  echo "Set LETSENCRYPT_EMAIL env var" >&2
  exit 1
fi

install_packages() {
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    jq \
    openssl \
    ufw \
    iptables-persistent \
    ipset \
    ipset-persistent \
    certbot
}

install_docker() {
  if command -v docker >/dev/null 2>&1; then
    return
  fi

  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg

  . /etc/os-release
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian ${VERSION_CODENAME} stable" \
    > /etc/apt/sources.list.d/docker.list

  apt-get update
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  systemctl enable --now docker
}

prepare_layout() {
  install -d -m 0750 "${DEPLOY_DIR}" "${DEPLOY_DIR}/config" "${DEPLOY_DIR}/certs" "${DEPLOY_DIR}/db"
}

write_env_template_if_missing() {
  if [[ ! -f "${ENV_FILE}" ]]; then
    local db_pass admin_pass
    db_pass=$(openssl rand -base64 30 | tr -d '=+/\n' | cut -c1-32)
    admin_pass=$(openssl rand -base64 24 | tr -d '=+/\n' | cut -c1-24)

    cat >"${ENV_FILE}" <<EOF
SIPIS_DB_PASSWORD=${db_pass}
SIPIS_ADMIN_PASSWORD=${admin_pass}
SIPIS_ADMIN_USERNAME=admin
SIPIS_PUBLIC_NAME=${DOMAIN}
SIPIS_SERVER_PORT=14998
SIPIS_HTTP_PORT=5000
LETSENCRYPT_EMAIL=${LETSENCRYPT_EMAIL}
EOF
    chmod 0600 "${ENV_FILE}"
  fi
}

write_compose_if_missing() {
  if [[ ! -f "${DEPLOY_DIR}/docker-compose.yml" ]]; then
    cat >"${DEPLOY_DIR}/docker-compose.yml" <<'EOF'
services:
  lb2:
    image: docker.acrobits.net/releases/lb2:latest
    container_name: lb2
    volumes:
      - ./certs:/certs:ro
    ports:
      - "24998:24998/tcp"
      - "4998:4998/tcp"
      - "4998:4998/udp"
    restart: unless-stopped

  dbsipis:
    image: docker.acrobits.net/releases/dbsipis:latest
    container_name: dbsipis
    env_file:
      - ./.env
    environment:
      - POSTGRES_PASSWORD=${SIPIS_DB_PASSWORD}
      - POSTGRES_USER=sipis
      - POSTGRES_DB=sipis
    volumes:
      - ./db:/var/lib/postgresql/data
    restart: unless-stopped

  sipis:
    image: docker.acrobits.net/releases/sipis:latest
    container_name: sipis
    depends_on:
      - dbsipis
    env_file:
      - ./.env
    volumes:
      - ./config:/etc/sipis
      - /etc/ssl/certs:/etc/ssl/certs:ro
    ports:
      - "127.0.0.1:5000:5000"
    restart: unless-stopped

  stunnelsipis:
    image: docker.acrobits.net/releases/stunnelsipis:latest
    container_name: stunnelsipis
    depends_on:
      - sipis
    volumes:
      - ./certs:/certs:ro
    ports:
      - "443:443/tcp"
    restart: unless-stopped

networks:
  default:
    name: sipis_net
EOF
  fi
}

write_settings_if_missing() {
  if [[ ! -f "${DEPLOY_DIR}/config/Settings.xml" ]]; then
    set -a
    # shellcheck disable=SC1090
    source "${ENV_FILE}"
    set +a

    cat >"${DEPLOY_DIR}/config/Settings.xml" <<EOF
<Sipis xmlns="http://acrobits.net/SipisSettings.xsd">
  <Server Name="SipisOn${SIPIS_PUBLIC_NAME}" Address="0.0.0.0" Port="${SIPIS_SERVER_PORT}" />
  <HttpServer Address="0.0.0.0" Port="${SIPIS_HTTP_PORT}" />
  <Administrator UserName="${SIPIS_ADMIN_USERNAME}" Password="${SIPIS_ADMIN_PASSWORD}" />
  <Database OpenString="host=dbsipis port=5432 dbname=sipis user=sipis password=${SIPIS_DB_PASSWORD}" />
  <Lock FileName="/var/run/Sipis.lock"/>
  <Log FileName="/dev/stdout" InstanceFileName="/dev/stdout" ProblematicInstancesAutomatically="Yes" Level="Debug" Stdio="Stdout">
    <Http RequestBody="Yes"></Http>
  </Log>
  <NotificationServers>
    <NotificationServer Name="*" Host="pnm.cloudsoftphone.com" Port="6552" Premium="No" RequiresTls="Yes" />
  </NotificationServers>
  <Instance UserAgent="Acrobits SIPIS on ${SIPIS_PUBLIC_NAME}">
    <MaxAge Days="3" Hours="0" Minutes="0" Seconds="0" />
    <PremiumMaxAge Days="7" Hours="0" Minutes="0" Seconds="0" />
    <NotRegisteredMaxAge Hours="12" />
    <AboutToExpireIn><Silent Hours="24" /><Intrusive Hours="12" /></AboutToExpireIn>
    <AboutToExpirePeriod><Silent Hours="1" /><Intrusive Hours="11" /></AboutToExpirePeriod>
    <KeepAlivePackets Enabled="Yes"><Period Days="0" Hours="0" Minutes="0" Seconds="30" /></KeepAlivePackets>
  </Instance>
  <IncomingCall><NotAnsweredMaxAge Days="0" Hours="0" Minutes="2" Seconds="0" /></IncomingCall>
  <IncomingTextMessage>
    <Filter>
      <Entry Action="AcceptAndDrop" Enabled="Yes"><Header Name="Content-Type" Equal="application/im-iscomposing+xml" /></Entry>
      <Entry Action="Reject" Enabled="Yes"><Header Name="Content-Length" UintGt="4194304" /><RejectWith Code="413" Phrase="Request Entity Too Large" /></Entry>
    </Filter>
  </IncomingTextMessage>
  <PushTest><MinAge Days="7" Hours="0" Minutes="0" Seconds="0" /></PushTest>
</Sipis>
EOF
    chmod 0600 "${DEPLOY_DIR}/config/Settings.xml"
  fi
}

issue_letsencrypt() {
  certbot certonly --non-interactive --agree-tos --email "${LETSENCRYPT_EMAIL}" --standalone -d "${DOMAIN}"
  cp "/etc/letsencrypt/live/${DOMAIN}/fullchain.pem" "${DEPLOY_DIR}/certs/fullchain.pem"
  cp "/etc/letsencrypt/live/${DOMAIN}/privkey.pem" "${DEPLOY_DIR}/certs/privkey.pem"
  chmod 0600 "${DEPLOY_DIR}/certs/privkey.pem"
  chmod 0644 "${DEPLOY_DIR}/certs/fullchain.pem"
}

configure_ufw() {
  ufw --force reset
  ufw default deny incoming
  ufw default allow outgoing

  if [[ -n "${ADMIN_IPS}" ]]; then
    IFS=',' read -r -a ip_list <<<"${ADMIN_IPS}"
    for ip in "${ip_list[@]}"; do
      ufw allow from "${ip}" to any port 22 proto tcp
      ufw allow from "${ip}" to any port 443 proto tcp
    done
  else
    echo "WARNING: ADMIN_IPS not set, 443 will not be opened" >&2
  fi

  ufw allow 4998/tcp
  ufw allow 4998/udp
  ufw allow 24998/tcp

  ufw deny 5000/tcp
  ufw --force enable
}

docker_registry_login_hint() {
  if ! grep -q 'docker.acrobits.net' ~/.docker/config.json 2>/dev/null; then
    cat <<'EOF'
INFO: Docker login for Acrobits registry may be required.
Run if image pull fails:
  docker login docker.acrobits.net
EOF
  fi
}

deploy() {
  cd "${DEPLOY_DIR}"
  docker compose pull
  docker compose up -d
}

print_postcheck() {
  cat <<'EOF'
Deployment finished.
Post-checks:
  docker ps
  docker logs --tail 100 sipis
  curl -k --digest -u admin:<password> https://127.0.0.1/stats

If needed, open /stats only for admin source IPs via firewall.
EOF
}

install_packages
install_docker
prepare_layout
write_env_template_if_missing
write_compose_if_missing
write_settings_if_missing
issue_letsencrypt
configure_ufw
docker_registry_login_hint
deploy
print_postcheck
