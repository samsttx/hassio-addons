# Changelog

## 3.4.2.3

- Fix `cors_origins` default: CouchDB splits the `origins` list on comma without trimming whitespace, so `"a, b, c"` produced origins with a leading space that never matched a real `Origin` header (Obsidian LiveSync reported `cors.origins is wrong`). Default is now `app://obsidian.md,capacitor://localhost,http://localhost`.

## 3.4.2.2

- Expose `enable_cors`, `cors_origins`, `cors_credentials`, `cors_methods`, `require_valid_user`, `max_http_request_size` and `max_document_size` options — needed for browser/app clients like Obsidian LiveSync.

## 3.4.2.1

- Expose `secret` and `bind_address` in Supervisor UI (missing entries in `options` block hid them).

## 3.4.2 — Initial release

- Initial release wrapping `couchdb:3.4.2`.
- Admin bootstrap via `username` / `password` options.
- Persistent data under `/config/couchdb/{data,views}`.
- Configurable `log_level` and `bind_address`.
