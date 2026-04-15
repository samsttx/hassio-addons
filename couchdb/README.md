# Home Assistant Add-on: CouchDB

![CouchDB Version](https://img.shields.io/badge/CouchDB-v3.4.2-red)

> ⚠️ **WARNING: This add-on is not fully tested. Please be careful and use at your own risk.**

[Apache CouchDB](https://couchdb.apache.org/) is a document-oriented NoSQL database with an HTTP/JSON API, replication, and the Fauxton web UI. Use it to store documents, replicate to/from other CouchDB or PouchDB nodes, or back Home Assistant integrations that speak CouchDB.

Features:
- HTTP/JSON API on port `5984`.
- Fauxton admin UI at `/_utils/`.
- Single-node mode with admin account bootstrapped from add-on options.
- Persistent data stored under `/config/couchdb/` on the host.

## Installation

You can add this repository to your Home Assistant instance by clicking the button below:

[![Add repository on my Home Assistant][repository-badge]][repository-url]

1. Click the button above.
2. Search for "CouchDB" in the Add-on Store.
3. Click **Install**.
4. Set at minimum a `username` and `password` in the configuration tab, then start the add-on.

## Configuration

See [DOCS.md](DOCS.md) for the full option reference and first-boot cluster setup.

## Support

If you find any issues, please open an issue in the GitHub repository.

[repository-badge]: https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg
[repository-url]: https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fsamsttx%2Fhassio-addons
