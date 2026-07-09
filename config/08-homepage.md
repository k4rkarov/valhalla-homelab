# Homepage

> Central dashboard for **Valhalla**.

---

## Purpose

Homepage centralizes links, widgets, and operational information for homelab services.

It is the visual entry point for:

- Portainer;
- Nginx Proxy Manager;
- AdGuard Home;
- Vaultwarden;
- Jellyfin;
- Navidrome;
- Uptime Kuma;
- future services.

The full DNS, HTTPS, and remote access flow is documented in [`00-architecture.md`](00-architecture.md).

---

## Operating Role

Whenever a new service is deployed, the final step is adding it to Homepage.

This avoids relying on memory for ports, IPs, or individual URLs.

---

## Docker Compose

Location:

```text
config/docker-compose-stacks/infra.yaml
```

Image:

```text
ghcr.io/gethomepage/homepage
```

Container:

```text
homepage
```

---

## Structure

Configuration:

```text
homepage-config
```

Main files:

| File | Purpose |
| --- | --- |
| `bookmarks.yaml` | Bookmarks |
| `services.yaml` | Service list |
| `widgets.yaml` | Widgets |
| `settings.yaml` | General settings |
| `docker.yaml` | Docker integration |

---

## Docker Socket

Homepage has read-only access to the Docker socket:

```text
/var/run/docker.sock
```

This allows it to display container state, uptime, images, and related information without extra agents.

---

## Access

| Type | Value |
| --- | --- |
| Internal | `http://homepage:3000` |
| Published port | `3000` |
| Recommended domain | `https://homepage.valhalla` |
| Proxy Host | `homepage` -> `3000` |
| DNS Rewrite | `homepage.valhalla` -> `192.168.1.50` |

The stack sets `HOMEPAGE_ALLOWED_HOSTS` for the real Valhalla access paths:

```text
homepage.valhalla,192.168.1.50:3000,100.127.100.50:3000
```

---

## Organization

Current categories:

- Infrastructure
  - Homepage
  - Portainer
  - Nginx Proxy Manager
  - AdGuard Home
  - Uptime Kuma
- Security
  - Vaultwarden
- Media
  - Karkaflix
  - Navidrome

New categories can be added as the environment grows.

---

## Visual Identity

The dashboard was customized to match the project identity:

- dark theme;
- nordic inspiration;
- animated runes;
- Berserker mode;
- light animations;
- custom layout.

---

## Backup

Include in backups:

```text
homepage-config
```

This directory preserves layout, categories, bookmarks, widgets, integrations, and settings.

---

## Troubleshooting

### Page does not open

```bash
docker ps
docker logs -f homepage
```

Check whether the `homepage` container is running.

### Service appears unavailable

Check:

- container name;
- configured port;
- entry in `services.yaml`;
- Docker integration.

### HTTPS does not work

Check:

- Proxy Host in NPM;
- wildcard certificate;
- DNS Rewrite;
- Root CA installed on the client.
