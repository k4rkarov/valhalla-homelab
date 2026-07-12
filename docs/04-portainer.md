# Portainer

> Docker management interface used by **Valhalla**.

---

## Purpose

Portainer provides a visual interface for routine Docker administration.

It helps with:

- stack management;
- container updates;
- logs;
- volumes;
- networks;
- container inspection;
- container consoles.

Portainer complements the Docker CLI. It does not replace it.

---

## Why Portainer

Portainer was chosen because it offers:

- good stability;
- mature interface;
- broad documentation;
- large community;
- complete Docker Engine management.

---

## Role

```text
Administrator
-> HTTPS
-> Nginx Proxy Manager
-> Portainer
-> Docker Engine
-> Containers
```

Portainer does not run the applications itself. It manages the Docker Engine.

---

## Docker Compose

Portainer is documented here as an administration option, but it is not currently part of the functional stack files under `docker/`.

Image:

```text
portainer/portainer-ce
```

Container:

```text
portainer
```

Example Compose:

```yaml
services:
  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    restart: unless-stopped
    ports:
      - "8000:8000"
      - "9443:9443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data

volumes:
  portainer_data:
```

---

## Important Mounts

| Mount | Purpose |
| --- | --- |
| `/var/run/docker.sock` | Allows Portainer to manage Docker |
| `portainer_data:/data` | Stores users, settings, stacks, and endpoints |

The Docker socket is the most important mount. Without it, Portainer cannot manage containers.

---

## Access

Initial access:

```text
https://192.168.1.50:9443
```

Recommended access after proxy setup:

```text
https://portainer.valhalla
```

---

## Stack Organization

The functional stacks currently tracked in `docker/` are:

- `infra`;
- `proxy`;
- `network`;
- `security`;
- `media`.

This keeps updates and maintenance isolated.

---

## Updating a Stack

Typical Portainer flow:

1. Open the stack.
2. Open the editor.
3. Update the Compose definition if needed.
4. Select `Update the stack`.
5. Validate logs and service health.

Portainer will pull images, recreate containers, and preserve volumes.

---

## Daily Operations

Useful sections:

| Section | Use |
| --- | --- |
| Containers | Status, ports, resource usage, uptime |
| Logs | Container logs |
| Console | Temporary shell access |
| Volumes | Persistent data inspection |
| Networks | Docker network inspection |
| Stacks | Compose-based deployments |

Prefer SSH and Docker CLI for advanced diagnostics and automation.

---

## Backup

Preserve:

```text
portainer_data
```

This volume contains users, stacks, endpoints, and settings.

---

## Recovery

After reinstalling Debian:

1. Install Docker.
2. Restore `portainer_data`.
3. Recreate the Portainer container.

Portainer should return to its previous state.

---

## Security

Access is protected through:

- HTTPS;
- the `*.valhalla` wildcard certificate;
- Portainer authentication;
- Tailscale for remote access.

Port `9443` must not be exposed to the public Internet.

---

## Useful Commands

```bash
docker ps
docker logs -f portainer
docker exec -it portainer sh
docker inspect portainer
docker stats
```

---

## Operating Philosophy

Portainer is for convenience. The command line remains the source of flexibility, diagnostics, and automation.
