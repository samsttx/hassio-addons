# Home Assistant Add-on: Yopass

![Yopass Version](https://img.shields.io/badge/Yopass-v13.1.0-blue)

> ⚠️ **WARNING: This add-on is not fully tested. Please be careful and use at your own risk.**

[Yopass](https://github.com/jhaals/yopass) is a self-hosted service for sharing end-to-end encrypted one-time secrets over HTTP. Encryption happens in the browser — the server only stores the ciphertext.

Features:
- Web UI and JSON API on port `1337`.
- Bundled in-container memcached backend — no external service required.
- Optional disk-backed file-store for large encrypted uploads, persisted under `/config/yopass/files`.
- Optional OIDC, branding, and audit log (require an upstream commercial license key).

## Installation

You can add this repository to your Home Assistant instance by clicking the button below:

[![Add repository on my Home Assistant][repository-badge]][repository-url]

1. Click the button above.
2. Search for "Yopass" in the Add-on Store.
3. Click **Install**.
4. Configure options (all optional — defaults work out of the box), then start the add-on.

## Configuration

See [DOCS.md](DOCS.md) for the full option reference.

## Support

If you find any issues, please open an issue in the GitHub repository.

[repository-badge]: https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg
[repository-url]: https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fsamsttx%2Fhassio-addons
