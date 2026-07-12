# Vaultwarden

> Self-hosted password manager for **Valhalla**.

---

## Purpose

Vaultwarden is the digital vault for Valhalla.

It stores, syncs, and protects infrastructure and personal credentials while keeping the database under the administrator's control.

It is compatible with official Bitwarden clients for desktop, mobile, and browsers.

---

## Infrastructure Role

Vaultwarden is the central repository for:

- passwords;
- passkeys;
- SSH keys;
- secure notes;
- cards;
- identities;
- TOTP secrets;
- recovery codes.

Credentials for new homelab services should be registered here.

---

## Docker Compose

Location:

```text
docker/security/compose.yml
```

Image:

```text
vaultwarden/server
```

Container:

```text
vaultwarden
```

---

## Structure

Persistence:

```text
vaultwarden-data
```

This directory contains users, vaults, attachments, organizations, settings, and the SQLite database.

---

## Access

| Type | Value |
| --- | --- |
| Internal | `http://vaultwarden:80` |
| Published port | `8080` |
| Recommended domain | `https://vault.valhalla` |
| Proxy Host | `vaultwarden` -> `80` |
| DNS Rewrite | `vault.valhalla` -> `192.168.1.50` |

The general access flow is documented in [`00-architecture.md`](00-architecture.md).

---

## Security

Configured setting:

```text
SIGNUPS_ALLOWED=true
```

Signups are currently enabled in the functional stack. Disable this after creating the intended users if the instance should be closed.

Passwords are encrypted client-side. The server stores encrypted data and cannot read plaintext credentials.

---

## Recommended Organization

Create separate collections for:

- infrastructure;
- external services;
- personal accounts;
- recovery codes;
- administrative keys and tokens.

Prefer passkeys and MFA whenever possible.

---

## Backup

Critical directory:

```text
vaultwarden-data
```

Backing up this directory preserves the full vault.

---

## Update

```bash
docker compose pull
docker compose up -d
```

Data is preserved as long as the persistent directory is kept.

---

## Troubleshooting

### Does not open

```bash
docker ps
docker logs -f vaultwarden
```

### HTTPS error

Check:

- Proxy Host;
- wildcard certificate;
- DNS Rewrite;
- installed Root CA.

### Does not sync

Check:

- HTTPS;
- DNS;
- Tailscale, when remote;
- server time.
