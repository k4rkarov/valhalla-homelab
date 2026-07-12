<h1 align="center">⚔️ VALHALLA ⚔️</h1>
<p align="center">A self-hosted homelab focused on privacy, simplicity, and infrastructure ownership.</p>
<h1 align="center"><img src="assets/images/valhalla.png"></h1>

## Overview

Valhalla is a personal homelab for running private services at home with Docker, internal DNS, HTTPS, and remote access through Tailscale. The goal is to keep control of data, avoid public exposure, and make everyday self-hosted tools feel approachable.

## Principles

- no public services unless strictly necessary;
- no router port forwarding;
- remote access through Tailscale;
- applications run in Docker containers;
- friendly internal names through AdGuard Home;
- centralized HTTPS with a private PKI;
- persistent data stored under `/srv`.

## What is included

The stack currently includes:

- Docker + Docker Compose;
- Nginx Proxy Manager for reverse proxy and TLS;
- AdGuard Home for internal DNS;
- Homepage as a dashboard;
- Vaultwarden for passwords;
- Jellyfin and Navidrome for media;
- Uptime Kuma for monitoring;
- Portainer for management.

## ⚠️ A Note on Infrastructure Management

Valhalla uses Docker Compose for reproducible deployments. While **Portainer** is included for convenient visualization and troubleshooting, please note the following:

- **Source of Truth:** The `compose.yml` files in this repository are the primary source of truth for your infrastructure.
- **Manual Changes:** Any changes made directly via the Portainer interface (e.g., stopping containers, editing environment variables) will **not** be reflected in your repository files.
- **Persistence:** If you run `./install.sh` again, your manual changes in Portainer may be overwritten to match the repository configuration. 

For permanent changes, please edit the corresponding `compose.yml` file and re-run the installer.

## Architecture at a glance

A typical request flows through local DNS, the reverse proxy, and then into the appropriate container. The full design is documented in [documentation/00-architecture.md](documentation/00-architecture.md).

## Hardware

The stack is intentionally lightweight and can run on a Raspberry Pi, a small mini PC, a NUC, or an older desktop. The full hardware notes are in [documentation/01-hardware.md](documentation/01-hardware.md).

## Documentation

The repository is organized into a set of service-specific guides:

- [documentation/00-architecture.md](documentation/00-architecture.md) — overall design
- [documentation/01-hardware.md](documentation/01-hardware.md) — hardware and network
- [documentation/02-os.md](documentation/02-os.md) — Debian host setup
- [documentation/03-docker.md](documentation/03-docker.md) — Docker and stacks
- [documentation/05-npm.md](documentation/05-npm.md) — reverse proxy
- [documentation/06-adguard.md](documentation/06-adguard.md) — DNS
- [documentation/07-tailscale.md](documentation/07-tailscale.md) — remote access
- [documentation/08-homepage.md](documentation/08-homepage.md) — dashboard
- [documentation/09-vaultwarden.md](documentation/09-vaultwarden.md) — password manager
- [documentation/10-jellyfin.md](documentation/10-jellyfin.md) — media server
- [documentation/11-navidrome.md](documentation/11-navidrome.md) — music server
- [documentation/12-uptime-kuma.md](documentation/12-uptime-kuma.md) — monitoring

## Hands on

> The docs on `config/` use neutral placeholders for security and privacy. Review them before deploying and adapt hostnames, usernames, IPs, and any service-specific values to your own environment.

### Install on a Debian-like Linux host

The easiest path is to run the installer directly:

```bash
curl -fsSL https://raw.githubusercontent.com/k4rkarov/valhalla-homelab/main/install.sh | bash
```

The installer will guide you through the setup, prepare Docker and supporting packages, create the needed directories, generate the compose configuration, and start the stack for you. During setup it will ask for a hostname, username, IP address, and an internal domain name. The default domain is `valhalla`, which is strongly recommended unless you have a specific reason to change it.

If you want to review the script first, clone the repo and run it locally:

```bash
git clone https://github.com/k4rkarov/valhalla-homelab.git
cd valhalla-homelab
./install.sh
```

Useful options:

```bash
./install.sh --help
./install.sh --check
./install.sh --dry-run --verbose
```

If you want help from an AI while installing, the repository includes [ai-context.md](ai-context.md), which summarizes the installer flow and the most important deployment details.
