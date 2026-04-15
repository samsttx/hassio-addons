#!/usr/bin/env bash
set -e

CONFIG_PATH=/data/options.json

echo "[INFO] Starting CouchDB Add-on: $(date)"

# Function to export simple keys
export_var() {
    local key=$1
    local env_name=$2
    local val=$(jq -r ".$key // empty" "$CONFIG_PATH")
    if [ -n "$val" ]; then
        export "$env_name"="$val"
        echo "[INFO] Set $env_name"
    fi
}

# Required admin credentials
export_var "username" "COUCHDB_USER"
export_var "password" "COUCHDB_PASSWORD"

# Optional cluster/session secret. If unset, generate once and persist under
# /config so it survives container restarts (otherwise sessions invalidate).
SECRET=$(jq -r '.secret // empty' "$CONFIG_PATH")
SECRET_FILE="/config/couchdb/.secret"
if [ -z "$SECRET" ]; then
    if [ -f "$SECRET_FILE" ]; then
        SECRET=$(cat "$SECRET_FILE")
        echo "[INFO] Loaded persisted COUCHDB_SECRET from $SECRET_FILE"
    else
        mkdir -p /config/couchdb
        SECRET=$(openssl rand -hex 32)
        echo -n "$SECRET" > "$SECRET_FILE"
        chmod 600 "$SECRET_FILE"
        echo "[INFO] Generated and persisted new COUCHDB_SECRET to $SECRET_FILE"
    fi
fi
export COUCHDB_SECRET="$SECRET"

# Persistent data/config under /config (mapped from host).
# Skip recursive chown when ownership already correct — walking a large DB
# every boot is expensive.
DATA_DIR="/config/couchdb/data"
VIEW_DIR="/config/couchdb/views"
mkdir -p "$DATA_DIR" "$VIEW_DIR"
if [ "$(stat -c %U /config/couchdb 2>/dev/null)" != "couchdb" ]; then
    chown -R couchdb:couchdb /config/couchdb
    echo "[INFO] Fixed ownership on /config/couchdb"
fi

# Override data paths + log level via local.d ini snippet
LOG_LEVEL=$(jq -r '.log_level // "info"' "$CONFIG_PATH")
BIND_ADDRESS=$(jq -r '.bind_address // "0.0.0.0"' "$CONFIG_PATH")

cat >/opt/couchdb/etc/local.d/hassio.ini <<EOF
[couchdb]
database_dir = $DATA_DIR
view_index_dir = $VIEW_DIR

[chttpd]
bind_address = $BIND_ADDRESS
port = 5984

[log]
level = $LOG_LEVEL
EOF

chown couchdb:couchdb /opt/couchdb/etc/local.d/hassio.ini
echo "[INFO] Wrote /opt/couchdb/etc/local.d/hassio.ini (data=$DATA_DIR, bind=$BIND_ADDRESS, log=$LOG_LEVEL)"

# Hand over to upstream entrypoint (handles admin bootstrap + single-node init)
echo "[INFO] Handing over to CouchDB entrypoint..."
exec tini -- /docker-entrypoint.sh /opt/couchdb/bin/couchdb
