# Tinyauth Configuration Documentation

Tinyauth is a lightweight authentication proxy that supports multiple backends. This add-on allows you to easily integrate it into your Home Assistant setup.

## General Configuration

- **app_title**: The title shown on the login page.
- **app_url (Required)**: The full public URL of your Tinyauth instance (e.g., `https://auth.mydomain.com`).
- **background_image**: URL to a custom background image for the login page.
- **database_path**: Path where the SQLite database will be stored (default is usually `/config/tinyauth.db`).
- **users**: A list of local users allowed to log in (format: `username:password_hash`).
- **oauth_auto_redirect**: Set to a provider ID (e.g., `google`, `github`) to automatically redirect users to that OAuth provider. If not set, users will see a login page with all configured providers.
- **oauth_whitelist**: A list of email addresses or domains allowed to log in via OAuth.
- **log_level**: Adjust the verbosity of logs (`debug`, `info`, `warn`, `error`).

## LDAP Configuration

If you wish to use an LDAP server for authentication, fill in the following:

- **ldap_address**: Address of the LDAP server (e.g., `ldap.example.com:389`).
- **ldap_base_dn**: The base DN for searches (e.g., `ou=users,dc=example,dc=com`).
- **ldap_bind_dn**: The DN to bind with for searching.
- **ldap_bind_password**: The password for the bind DN.
- **ldap_insecure**: Set to `true` to allow insecure connections to the LDAP server (not recommended).
- **ldap_search_filter**: The filter used to search for users (e.g., `(uid=%s)`).

## OAuth Providers (Dynamic)

You can add multiple OAuth providers (Google, GitHub, Authelia, etc.) in the **providers** list.

### How it works:
1.  **ID**: The internal identifier (e.g., `google`, `github`).
2.  **Known Providers**: For common providers like `google` or `github`, Tinyauth knows the default URLs. You only need to provide the `client_id` and `client_secret`.
3.  **Custom Providers**: For custom OIDC providers, you must also specify `auth_url`, `token_url`, and `user_info_url`.

### Example Provider Entry:
```yaml
- id: google
  client_id: YOUR_CLIENT_ID
  client_secret: YOUR_CLIENT_SECRET
```

### Advanced Fields:
- **name**: Optional display name for the provider.
- **scopes**: Override default OAuth scopes.
- **redirect_url**: Explicitly set the redirect URL if auto-detection fails.
- **insecure_skip_verify**: Set to `true` if your provider uses a self-signed certificate.
