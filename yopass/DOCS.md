# Yopass Configuration Documentation

This add-on runs [Yopass](https://github.com/jhaals/yopass) 13.1.0. Secrets are encrypted in the browser; the server stores only ciphertext in an in-container memcached (ephemeral by design — one-time-use, TTL ≤ 1 week).

## Options

### Core

- **max_length**: Max encrypted secret length in bytes. Default `10000`.
- **max_file_size**: Max encrypted file upload size in bytes. Default `524288`. Hard-capped at `1048576` (1 MiB) without a license key.
- **default_expiry**: Default secret lifetime. One of `1h`, `1d`, `1w`.
- **log_level**: One of `trace`, `debug`, `info`, `warn`, `error`, `fatal`, `panic`.
- **force_onetime_secrets**: Force every secret to be one-time readable.
- **disable_upload**: Disable file uploads (text secrets still work).
- **read_only**: Block secret creation; existing secrets remain readable.
- **cors_allow_origin**: Allowed CORS origin. Default `*`.
- **trusted_proxies**: Reverse-proxy IPs/CIDRs whose `X-Forwarded-For` headers should be trusted.
- **privacy_notice_url** / **imprint_url**: Optional footer links.
- **prefetch_secret**: Prefetch metadata on page load (default on).
- **disable_features** / **no_language_switcher**: UI trimming.

### Disk file-store (optional)

- **file_store_enabled**: When `true`, large encrypted files are persisted under `/config/yopass/files` (via `FILE_STORE=disk`) and survive container restarts. When `false`, files live only in memcached.
- **cleanup_interval**: Purge interval for expired file-store entries. Default upstream is `60s`.

### License-gated (require `license_key`)

Yopass features below need a commercial license key from upstream — setting the options without a license is harmless but they stay inactive.

- **license_key**: The license key itself.
- **app_name**, **logo_url**, **theme_light**, **theme_dark**: Branding.
- **oidc_issuer**, **oidc_client_id**, **oidc_client_secret**, **oidc_redirect_url**, **require_auth**, **frontend_url**, **oidc_allowed_domains**: OIDC single sign-on.
- **audit_log**: Write create/read events to `/config/yopass/audit.log`.

## Persistent storage

The container maps `/config` from the host. The add-on writes to:

- `/config/yopass/files/` — disk file-store (only if `file_store_enabled: true`).
- `/config/yopass/.oidc-session-key` — auto-generated 32-byte hex key used to sign OIDC session cookies. Created once on first OIDC start and reused on every boot so logins survive restarts.
- `/config/yopass/audit.log` — audit log (only if `audit_log: true`).

Removing the add-on does **not** delete these files. To fully reset, stop the add-on and remove `/config/yopass/` via SSH / File editor.

## Architecture notes

- Yopass requires a memcached or redis backend. This add-on bundles memcached inside the container and starts it from `rootfs/run.sh` before launching `yopass-server`, so the add-on is self-contained and does not need a companion add-on.
- Memcached is pinned to `127.0.0.1:11211`, allocated 64 MiB, and is not reachable from outside the container.
- The upstream Yopass image is distroless. The Dockerfile rebuilds on Alpine and copies `/yopass-server` plus the `/public` web assets out of `jhaals/yopass:13.1.0`.

## Verifying it runs

```bash
curl http://<ha-host>:1337/
# -> HTML for the Yopass UI
```

## Accessing from Home Assistant integrations

Inside the Supervisor network, the add-on is reachable at `http://<slug>:1337`, i.e. `http://local-yopass:1337` when installed from this repo (the `local-` prefix is appended by Supervisor for local repositories).
