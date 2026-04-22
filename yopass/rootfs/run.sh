#!/usr/bin/env bash
set -e

CONFIG_PATH=/data/options.json

echo "[INFO] Starting Yopass Add-on: $(date)"

# Yopass uses viper AutomaticEnv: every flag `foo-bar` binds to env FOO_BAR.
export_var() {
    local key=$1
    local env_name=$2
    local val=$(jq -r ".$key // empty" "$CONFIG_PATH")
    if [ -n "$val" ] && [ "$val" != "null" ]; then
        export "$env_name"="$val"
        echo "[INFO] Set $env_name"
    fi
}

# Core server options
export_var "max_length" "MAX_LENGTH"
export_var "max_file_size" "MAX_FILE_SIZE"
export_var "default_expiry" "DEFAULT_EXPIRY"
export_var "log_level" "LOG_LEVEL"
export_var "force_onetime_secrets" "FORCE_ONETIME_SECRETS"
export_var "disable_upload" "DISABLE_UPLOAD"
export_var "read_only" "READ_ONLY"
export_var "disable_features" "DISABLE_FEATURES"
export_var "no_language_switcher" "NO_LANGUAGE_SWITCHER"
export_var "cors_allow_origin" "CORS_ALLOW_ORIGIN"
export_var "privacy_notice_url" "PRIVACY_NOTICE_URL"
export_var "imprint_url" "IMPRINT_URL"
export_var "prefetch_secret" "PREFETCH_SECRET"
export_var "cleanup_interval" "CLEANUP_INTERVAL"

# Branding / license-gated
export_var "license_key" "LICENSE_KEY"
export_var "app_name" "APP_NAME"
export_var "logo_url" "LOGO_URL"
export_var "theme_light" "THEME_LIGHT"
export_var "theme_dark" "THEME_DARK"

# OIDC (license-gated)
export_var "oidc_issuer" "OIDC_ISSUER"
export_var "oidc_client_id" "OIDC_CLIENT_ID"
export_var "oidc_client_secret" "OIDC_CLIENT_SECRET"
export_var "oidc_redirect_url" "OIDC_REDIRECT_URL"
export_var "require_auth" "REQUIRE_AUTH"
export_var "frontend_url" "FRONTEND_URL"
export_var "audit_log" "AUDIT_LOG"

# Comma-joined list flags
TRUSTED_PROXIES=$(jq -r '.trusted_proxies | select(. != null) | join(",")' "$CONFIG_PATH")
if [ -n "$TRUSTED_PROXIES" ]; then
    export TRUSTED_PROXIES
    echo "[INFO] Set TRUSTED_PROXIES"
fi

OIDC_ALLOWED_DOMAINS=$(jq -r '.oidc_allowed_domains | select(. != null) | join(",")' "$CONFIG_PATH")
if [ -n "$OIDC_ALLOWED_DOMAINS" ]; then
    export OIDC_ALLOWED_DOMAINS
    echo "[INFO] Set OIDC_ALLOWED_DOMAINS"
fi

# OIDC session key: generate-once, persist under /config so logins survive
# container restarts. Only needed when OIDC is configured, but cheap to keep.
if [ -n "$OIDC_ISSUER" ]; then
    SESSION_KEY_FILE="/config/yopass/.oidc-session-key"
    if [ -f "$SESSION_KEY_FILE" ]; then
        OIDC_SESSION_KEY=$(cat "$SESSION_KEY_FILE")
        echo "[INFO] Loaded persisted OIDC_SESSION_KEY from $SESSION_KEY_FILE"
    else
        mkdir -p /config/yopass
        OIDC_SESSION_KEY=$(openssl rand -hex 32)
        echo -n "$OIDC_SESSION_KEY" > "$SESSION_KEY_FILE"
        chmod 600 "$SESSION_KEY_FILE"
        echo "[INFO] Generated and persisted new OIDC_SESSION_KEY to $SESSION_KEY_FILE"
    fi
    export OIDC_SESSION_KEY
fi

# Optional disk file-store — backs large-file uploads onto /config so they
# survive restarts. Enable with file_store_enabled=true in options.
FILE_STORE_ENABLED=$(jq -r '.file_store_enabled // false' "$CONFIG_PATH")
if [ "$FILE_STORE_ENABLED" = "true" ]; then
    mkdir -p /config/yopass/files
    export FILE_STORE="disk"
    export FILE_STORE_PATH="/config/yopass/files"
    echo "[INFO] Set FILE_STORE=disk, FILE_STORE_PATH=/config/yopass/files"
fi

# Audit log path — persist if audit_log enabled.
if [ "${AUDIT_LOG:-false}" = "true" ]; then
    mkdir -p /config/yopass
    export AUDIT_LOG_FILE="/config/yopass/audit.log"
    echo "[INFO] Set AUDIT_LOG_FILE=/config/yopass/audit.log"
fi

# Internal backend: bundle memcached in-container so the add-on is self-contained.
# Runs in background; yopass-server defaults to localhost:11211.
echo "[INFO] Starting bundled memcached on 127.0.0.1:11211..."
memcached -d -u memcached -l 127.0.0.1 -p 11211 -m 64

# Yopass always listens on the addon-exposed port
export ADDRESS="0.0.0.0"
export PORT="1337"
export DATABASE="memcached"
export MEMCACHED="localhost:11211"

echo "[INFO] Handing over to yopass-server..."
exec /yopass-server
