# Changelog

## 3.4.2.1

- Expose `secret` and `bind_address` in Supervisor UI (missing entries in `options` block hid them).

## 3.4.2 — Initial release

- Initial release wrapping `couchdb:3.4.2`.
- Admin bootstrap via `username` / `password` options.
- Persistent data under `/config/couchdb/{data,views}`.
- Configurable `log_level` and `bind_address`.
