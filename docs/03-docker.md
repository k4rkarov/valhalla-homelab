# Docker

> Container platform used by **Valhalla**.

---

## Purpose

Valhalla is built around Docker. Debian provides the host layer, while services run as isolated containers.

This provides:

- isolation;
- easier updates;
- portability;
- fast recovery;
- reproducible deployments.

---

## Philosophy

Do not install an application directly on the host when it can reasonably run in a container.

Host-level exceptions:

- Docker Engine;
- Docker Compose;
- Tailscale;
- OpenSSH;
- UFW.

---

## Components

### Docker Engine

The service responsible for running containers.

```bash
sudo systemctl status docker
sudo systemctl start docker
sudo systemctl enable docker
```

### Docker Compose

Docker Compose describes applications through YAML files. Valhalla stacks are defined this way to keep deployments versioned, documented, and recoverable.

---

## Core Concepts

| Concept | Description |
| --- | --- |
| Image | Immutable template used to create containers |
| Container | Running instance of an image |
| Volume | Persistent data managed by Docker |
| Bind mount | Host directory mounted into a container |
| Network | Docker network used for container communication |

Valhalla prefers bind mounts for important data because they simplify inspection, backups, and migration.

---

## Stack Organization

| Stack | Services |
| --- | --- |
| `infra` | Homepage, Uptime Kuma |
| `proxy` | Nginx Proxy Manager |
| `network` | AdGuard Home |
| `security` | Vaultwarden |
| `media` | Jellyfin, Navidrome |

---

## Directory Structure

Base path:

```text
/srv/docker
```

Suggested structure:

```text
/srv/docker
├── infra
│   ├── compose.yml
│   └── data
├── proxy
│   ├── compose.yml
│   └── data
├── network
│   ├── compose.yml
│   └── data
├── security
│   ├── compose.yml
│   └── data
└── media
│   ├── compose.yml
│   └── data
```

---

## Images

| Service | Image |
| --- | --- |
| Portainer | `portainer/portainer-ce` |
| Homepage | `ghcr.io/gethomepage/homepage` |
| Nginx Proxy Manager | `jc21/nginx-proxy-manager` |
| Vaultwarden | `vaultwarden/server` |
| AdGuard Home | `adguard/adguardhome` |
| Jellyfin | `jellyfin/jellyfin` |
| Navidrome | `deluan/navidrome` |
| Uptime Kuma | `louislam/uptime-kuma` |

---

## Fundamental Commands

```bash
docker ps
docker ps -a
docker images
docker volume ls
docker network ls
docker system df
docker logs <container>
docker logs -f <container>
docker exec -it <container> sh
docker inspect <container>
docker stats
docker port <container>
docker events
```

---

## Updates

Update a stack:

```bash
cd /srv/docker/media
docker compose pull
docker compose up -d
```

Persistent data is preserved as long as volumes and bind mounts remain intact.

---

## Backup

Docker itself does not need a special backup. Preserve:

- Compose files;
- bind mount directories;
- named volumes when used;
- certificates;
- application databases.

Most important data lives under:

```text
/srv
```

---

## Recovery

After reinstalling Debian and Docker:

1. Restore Compose files or clone the repository.
2. Restore persistent directories.
3. Run `docker compose up -d` for each stack.

Services should be rebuilt automatically.

---

## Cleanup

```bash
docker container prune
docker image prune
docker system prune
docker system prune -a --volumes
```

Use volume cleanup only when you are certain no important data is attached.

---

## Conventions

- One application per container.
- One responsibility per stack.
- Descriptive container names.
- Persistent data outside containers.
- Configuration versioned when possible.
- Updates through Compose.
- Do not make permanent changes inside running containers.
