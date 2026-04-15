# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

Home Assistant add-on repository consumed by Supervisor via `repository.yaml`. Each top-level directory is one installable add-on. Current add-ons:

- `tinyauth/` — auth proxy wrapping `ghcr.io/steveiliop56/tinyauth` (Alpine base, `apk`).
- `couchdb/` — Apache CouchDB wrapping official `couchdb:3.4.2` (Debian base, `apt`).

Users install by adding the repo URL to Home Assistant's add-on store.

## Architecture

Each add-on follows the Home Assistant add-on contract:

- `config.yaml` — add-on manifest. Declares `slug`, `version`, `arch`, exposed `ports`, `map` (host paths mounted into container), `options` (defaults) and `schema` (typed validation rules Supervisor enforces before launch).
- `Dockerfile` — wraps the upstream image, installs `bash`/`jq`/`curl`/`tzdata` (use `apk` for Alpine bases like tinyauth, `apt-get` for Debian bases like couchdb), copies `rootfs/run.sh`, sets it as `ENTRYPOINT`. No `init` system (`init: false` in config.yaml).
- `rootfs/run.sh` — bridges Supervisor config to the upstream binary. At container start, Supervisor writes user options to `/data/options.json`; the script `jq`s values out, exports them as `UPPER_CASE` env vars the upstream binary expects, then `exec`s the upstream entrypoint. Tinyauth `exec`s the binary directly (`/tinyauth/tinyauth`); CouchDB preserves the upstream init by `exec tini -- /docker-entrypoint.sh /opt/couchdb/bin/couchdb` so the official admin-bootstrap logic runs.
- `translations/en.yaml` — labels/descriptions shown in the Supervisor UI for each `schema` key.
- `DOCS.md` — rendered in the Supervisor UI's "Documentation" tab.
- `.config.yml` — developer's local options sandbox (gitignored, contains real secrets — never commit).

### Config → env mapping patterns

Patterns used in `rootfs/run.sh` across add-ons:

1. **Scalars** — `export_var "key_name" "ENV_NAME"`. Empty/null values skipped. (both add-ons)
2. **List joins** — comma-joined into a single env var; tinyauth uses this for `users` → `USERS` and `oauth_whitelist` → `OAUTH_WHITELIST`.
3. **Dynamic providers** — tinyauth iterates `providers[]`; each entry's `id` uppercased, fields exported as `PROVIDERS_<ID>_CLIENT_ID`, `PROVIDERS_<ID>_CLIENT_SECRET`, `PROVIDERS_<ID>_AUTH_URL`, etc. Adding a new provider field requires updating both the `schema` in `config.yaml` AND the `FIELDS` array in `tinyauth/rootfs/run.sh`.
4. **INI snippet generation** — couchdb writes `/opt/couchdb/etc/local.d/hassio.ini` from option values to override `database_dir`, `view_index_dir`, `bind_address`, `log.level`. Use this when the upstream binary takes config files rather than env vars.
5. **Persisted generated secrets** — couchdb generates a 32-byte hex `COUCHDB_SECRET` on first boot and persists it to `/config/couchdb/.secret` so it survives container restarts (otherwise active sessions invalidate every restart). Re-use this pattern for any "generate-once" secret.

## Release workflow

Bumping an add-on's upstream version requires synchronized edits across four files in that add-on's directory:

1. `Dockerfile` — `FROM <image>:<tag>`
2. `config.yaml` — `version: "X.Y.Z"` (Supervisor shows "update available" when this changes)
3. `README.md` — version badge
4. `CHANGELOG.md` — add entry

Home Assistant re-pulls the image on version bump.

## Adding a new add-on

1. Create `<slug>/` at repo root with `config.yaml`, `Dockerfile`, `README.md`, `DOCS.md`, `CHANGELOG.md`, `icon.png`, `logo.png`.
2. Add shell wrapper at `<slug>/rootfs/run.sh` if the upstream image needs env-var translation from Supervisor options.
3. Add translations at `<slug>/translations/en.yaml`.
4. Reference from repo-root `README.md`.

## Testing locally

No build/test commands in this repo — validation happens inside Home Assistant. To test:

1. Point a Home Assistant Supervisor instance at a fork/branch via "Add repository".
2. Install and check logs via the add-on's Log tab.
3. `rootfs/run.sh` prints `[INFO] Set <VAR>` lines for every option it exports — useful for debugging missing options.

For Docker-only smoke tests without HA, you can build the image and run with a mocked options file:

```bash
docker build -t tinyauth-addon tinyauth/
docker run --rm -v $(pwd)/tinyauth/.config.yml:/data/options.json tinyauth-addon
```

(Note: `.config.yml` is YAML; Supervisor writes JSON to `/data/options.json`. For real parity, convert to JSON first.)

## Secrets

`.config.yml` in each add-on holds real dev secrets (OAuth client secrets, passwords, emails) and is gitignored globally. Never stage it. Never paste its contents into commits, PRs, or issues.
