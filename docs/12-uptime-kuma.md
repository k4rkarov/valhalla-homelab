# Uptime Kuma

> Availability monitoring for the **Valhalla** services.

---

## Purpose

Uptime Kuma continuously checks whether Valhalla services are reachable, responding correctly, and performing within an acceptable response time.

It is not meant to replace system-level metrics tools. Its main job is service availability: DNS, proxy, TLS, and application reachability.

The full access flow is documented in [`00-architecture.md`](00-architecture.md).

---

## Role

Uptime Kuma actively monitors:

- service availability;
- Nginx Proxy Manager routing;
- internal domain resolution;
- HTTPS certificates;
- application latency;
- service response time.

When configured, it can send notifications through external providers.

---

## Docker Compose

Location:

```text
docker/infra/compose.yml
```

Image:

```text
louislam/uptime-kuma
```

Container:

```text
uptime-kuma
```

---

## Structure

Persistent data:

```text
uptime-kuma-data
```

This directory stores the SQLite database, users, monitors, dashboards, settings, and history.

---

## Access

| Type | Value |
| --- | --- |
| Internal | `http://uptime-kuma:3001` |
| Published port | `3001` |
| Recommended domain | `https://status.valhalla` |
| Proxy Host | `uptime-kuma` -> `3001` |
| DNS Rewrite | `status.valhalla` -> `192.168.1.50` |

If `status.valhalla` does not exist yet, create its DNS Rewrite and Proxy Host following the standard service procedure in [`00-architecture.md`](00-architecture.md).

---

## Recommended Monitors

At minimum, monitor:

| Service | Suggested monitor |
| --- | --- |
| Homepage | HTTPS |
| Portainer | HTTPS |
| Nginx Proxy Manager | HTTPS |
| AdGuard Home | HTTPS and DNS |
| Vaultwarden | HTTPS |
| Jellyfin | HTTPS |
| Navidrome | HTTPS |
| Debian host | Ping |

New containers should be added as they become part of the environment.

---

## Monitor Types

Useful monitor types for Valhalla:

| Type | Use |
| --- | --- |
| HTTP(s) | Validate URL, status code, TLS, and response time |
| TCP | Check whether a port is open |
| Ping | Check whether a host is reachable |
| DNS | Validate domain resolution through AdGuard |

Examples:

```text
https://homepage.valhalla
192.168.1.50:53
homepage.valhalla
```

---

## Timing

Recommended interval:

```text
60 seconds
```

Recommended timeout:

```text
30 seconds
```

This balances quick detection with low resource usage.

---

## Certificates

Uptime Kuma can monitor:

- certificate validity;
- expiration date;
- certificate chain;
- TLS errors.

This is especially useful because Valhalla uses an internal CA.

---

## Notifications

Uptime Kuma supports many notification providers, including:

- Discord;
- Telegram;
- Slack;
- Email;
- Gotify;
- ntfy;
- Webhook;
- Matrix;
- Microsoft Teams.

At least one notification channel is recommended for critical alerts.

---

## Backup

Include in backups:

```text
uptime-kuma-data
```

This directory preserves:

- SQLite database;
- users;
- dashboards;
- monitors;
- history;
- notification settings.

---

## Update

```bash
docker compose pull
docker compose up -d
```

Settings remain preserved as long as the persistent directory is kept.

---

## Resource Usage

Uptime Kuma is lightweight.

Typical usage:

- CPU: below 1% in normal conditions;
- RAM: around 100-200 MB.

It is suitable for continuous use on modest hardware.

---

## Troubleshooting

### Monitor always offline

Check:

- Proxy Host;
- DNS Rewrite;
- target container;
- firewall;
- certificate trust.

### HTTPS check failing

Check:

- wildcard certificate;
- Root CA trust;
- TLS settings in the Proxy Host.

### High response time

Usually indicates:

- overloaded container;
- network issue;
- slow storage;
- host resource pressure.

Host checks:

```bash
htop
free -h
df -h
```

### DNS monitor failing

```bash
dig homepage.valhalla
nslookup homepage.valhalla
```

If these fail, check AdGuard Home first.

---

## Operating Decision

Uptime Kuma validates the same path real users take: domain, DNS, proxy, TLS, and application response.

This makes it more useful for availability checks than only verifying whether a container process is running.
