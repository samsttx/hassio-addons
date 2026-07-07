# CouchDB Configuration Documentation

This add-on runs [Apache CouchDB](https://couchdb.apache.org/) 3.4.2 in single-node mode, with persistent storage under `/config/couchdb/` on the Home Assistant host.

## Options

- **username (Required)**: Admin username created on first boot. Mapped to `COUCHDB_USER`.
- **password (Required)**: Admin password. Mapped to `COUCHDB_PASSWORD`. Set before the first start — the admin is only created once.
- **secret**: Shared secret used for session cookies and (future) cluster auth. Mapped to `COUCHDB_SECRET`. Leave blank and the add-on generates a 32-byte hex secret on first boot and persists it to `/config/couchdb/.secret` so sessions survive container restarts. Set explicitly (e.g. `openssl rand -hex 32`) if you want to manage rotation yourself or share the secret across nodes.
- **log_level**: One of `debug`, `info`, `notice`, `warning`, `error`, `critical`, `none`. Defaults to `info`.
- **bind_address**: HTTP bind address. Defaults to `0.0.0.0` (all IPv4 interfaces, required for the Supervisor port proxy). Set to `127.0.0.1` only if you will reach CouchDB through another add-on's internal network.
- **enable_cors**: Allow cross-origin requests. Defaults to `true`. Written to both `[httpd]` and `[chttpd]` (CouchDB checks either depending on version).
- **cors_origins**: Comma-separated list of allowed origins, **no spaces** — CouchDB splits on comma without trimming, so a space produces an origin that never matches a real `Origin` header. Defaults to `app://obsidian.md,capacitor://localhost,http://localhost` (covers Obsidian LiveSync).
- **cors_credentials**: Whether CORS requests may include credentials (cookies/auth headers). Defaults to `true`.
- **cors_methods**: Comma-separated list of allowed HTTP methods for CORS requests. Defaults to `GET, PUT, POST, HEAD, DELETE`.
- **require_valid_user**: Reject anonymous requests. Defaults to `true`.
- **max_http_request_size**: Max size in bytes of an incoming HTTP request body. Defaults to `4294967296` (4 GiB).
- **max_document_size**: Max size in bytes of a single document. Defaults to `4294967296` (4 GiB).

## Persistent storage

Databases and view indexes live under `/config/couchdb/` on the host, which maps into the container as:

- `/config/couchdb/data` — primary database files (`COUCHDB_DATABASE_DIR`).
- `/config/couchdb/views` — view index files.

Removing the add-on does **not** delete these directories. To fully reset, stop the add-on and remove `/config/couchdb/` via the SSH / File editor add-on.

## First-boot cluster setup

CouchDB 3.x creates the admin user from `COUCHDB_USER` / `COUCHDB_PASSWORD` on first start, but the three system databases (`_users`, `_replicator`, `_global_changes`) are not created automatically. Finish single-node setup once by calling `_cluster_setup`:

```bash
curl -X POST http://<ha-host>:5984/_cluster_setup \
  -u <username>:<password> \
  -H "Content-Type: application/json" \
  -d '{"action": "enable_single_node", "bind_address": "0.0.0.0", "username": "<username>", "password": "<password>", "port": 5984, "singlenode": true}'
```

Or open the Fauxton UI at `http://<ha-host>:5984/_utils/` and use the built-in setup wizard.

## Verifying it runs

```bash
curl http://<ha-host>:5984/
# -> {"couchdb":"Welcome","version":"3.4.2", ...}

curl -u <username>:<password> http://<ha-host>:5984/_up
# -> {"status":"ok","seeds":{}}
```

## Accessing from Home Assistant integrations

Inside the Supervisor network, the add-on is reachable at `http://<slug>:5984`, i.e. `http://local-couchdb:5984` when installed from this repo (the `local-` prefix is appended by Supervisor for local repositories).
