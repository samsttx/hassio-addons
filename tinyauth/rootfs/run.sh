#!/usr/bin/env bash
set -e

CONFIG_PATH=/data/options.json

echo "[INFO] Starting Tinyauth Add-on: $(date)"

# Function to export simple keys
export_var() {
    local key=$1
    local env_name=$2
    local val=$(jq -r ".$key // empty" $CONFIG_PATH)
    if [ ! -z "$val" ]; then
        export "$env_name"="$val"
        echo "[INFO] Set $env_name"
    fi
}

# General Configuration Mapping
export_var "app_title" "APP_TITLE"
export_var "app_url" "APP_URL"
export_var "background_image" "BACKGROUND_IMAGE"
export_var "database_path" "DATABASE_PATH"
export_var "disable_analytics" "DISABLE_ANALYTICS"
export_var "disable_resources" "DISABLE_RESOURCES"
export_var "disable_ui_warnings" "DISABLE_UI_WARNINGS"
export_var "forgot_password_message" "FORGOT_PASSWORD_MESSAGE"
export_var "log_json" "LOG_JSON"
export_var "log_level" "LOG_LEVEL"
export_var "login_max_retries" "LOGIN_MAX_RETRIES"
export_var "login_timeout" "LOGIN_TIMEOUT"
export_var "oauth_auto_redirect" "OAUTH_AUTO_REDIRECT"
export_var "secure_cookie" "SECURE_COOKIE"
export_var "session_expiry" "SESSION_EXPIRY"
export_var "trusted_proxies" "TRUSTED_PROXIES"

# Mapping Lists (Joined by commas)
USERS=$(jq -r '.users | select(. != null) | join(",")' $CONFIG_PATH)
if [ ! -z "$USERS" ]; then
    export USERS="$USERS"
    echo "[INFO] Set USERS"
fi

OAUTH_WHITELIST=$(jq -r '.oauth_whitelist | select(. != null) | join(",")' $CONFIG_PATH)
if [ ! -z "$OAUTH_WHITELIST" ]; then
    export OAUTH_WHITELIST="$OAUTH_WHITELIST"
    echo "[INFO] Set OAUTH_WHITELIST"
fi

# LDAP Configuration Mapping
export_var "ldap_address" "LDAP_ADDRESS"
export_var "ldap_base_dn" "LDAP_BASE_DN"
export_var "ldap_bind_dn" "LDAP_BIND_DN"
export_var "ldap_bind_password" "LDAP_BIND_PASSWORD"
export_var "ldap_insecure" "LDAP_INSECURE"
export_var "ldap_search_filter" "LDAP_SEARCH_FILTER"

# Dynamic Providers Loop
NUM_PROVIDERS=$(jq '.providers | length' $CONFIG_PATH)

for (( i=0; i<$NUM_PROVIDERS; i++ )); do
    ID=$(jq -r ".providers[$i].id" $CONFIG_PATH)
    UPPER_ID=$(echo "$ID" | tr '[:lower:]' '[:upper:]')
    
    echo "[INFO] Configuring OAuth Provider: $ID"
    
    # Required fields
    export "PROVIDERS_${UPPER_ID}_CLIENT_ID"=$(jq -r ".providers[$i].client_id" $CONFIG_PATH)
    export "PROVIDERS_${UPPER_ID}_CLIENT_SECRET"=$(jq -r ".providers[$i].client_secret" $CONFIG_PATH)
    
    # Optional fields
    FIELDS=("name" "auth_url" "token_url" "user_info_url" "redirect_url" "scopes" "insecure_skip_verify")
    for FIELD in "${FIELDS[@]}"; do
        VAL=$(jq -r ".providers[$i].$FIELD // empty" $CONFIG_PATH)
        if [ ! -z "$VAL" ]; then
            UPPER_FIELD=$(echo "$FIELD" | tr '[:lower:]' '[:upper:]')
            export "PROVIDERS_${UPPER_ID}_${UPPER_FIELD}"="$VAL"
        fi
    done
done

# Run Tinyauth
echo "[INFO] Handing over to Tinyauth binary..."
exec /tinyauth/tinyauth
