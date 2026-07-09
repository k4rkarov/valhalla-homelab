# AI Context for Valhalla Homelab

This file summarizes the repository structure, installer behavior, and the conventions that matter when debugging or extending the homelab setup.

## Project goal

Valhalla is a self-hosted homelab stack for Debian-like Linux hosts. It is designed to be simple, private, and mostly self-contained, using Docker Compose stacks plus a small set of supporting services.

## Repository layout

- README.md — high-level overview and quick start.
- install.sh — automated installer and verification entrypoint.
- config/ — service documentation and Docker Compose stack definitions.
  - config/docker-compose-stacks/infra.yaml
  - config/docker-compose-stacks/proxy.yaml
  - config/docker-compose-stacks/network.yaml
  - config/docker-compose-stacks/security.yaml
  - config/docker-compose-stacks/media.yaml
- images/ — screenshots and artwork used by the docs.

## Install script behavior

The installer is implemented in install.sh and should be treated as the primary automation entrypoint.

### Important behavior

- It targets Debian/Ubuntu/Raspberry Pi OS-like systems.
- It expects to run with root privileges. If it is launched without them, it will try to re-execute itself with sudo.
- It auto-detects a few host defaults:
  - hostname
  - current user
  - primary IP address
- It prompts the user to confirm or override those defaults.
- It also prompts for an internal domain name, defaulting to valhalla and recommending that value because it is the original project name.
- It stores the selected values in /etc/valhalla/install.env.
- It writes compose defaults to /etc/valhalla/compose.env.
- It installs base packages, Docker, Docker Compose, and Tailscale if needed.
- It creates persistent directories under /srv.
- It copies Docker Compose stack definitions into /srv/docker/* and renders them with the host and Tailscale IP values.
- It deploys the stacks using Docker Compose.

### Relevant flags

- -h, --help — show usage.
- -v, --verbose — print detailed steps while running.
- -c, --check — verify whether the stack looks installed and working.
- --dry-run — preview the actions without changing the host.

### Safe assumptions

- The installer should not silently change important values. Hostname changes should be confirmed by the user.
- The installer should keep the existing stack logic intact and avoid changing the runtime compose definitions unless necessary.
- The docs are intentionally written with neutral placeholders for privacy and security. Replace them with real values in your own deployment.

## Compose stack layout

The runtime stack definitions live under config/docker-compose-stacks and are copied into /srv/docker/<stack>/compose.yml by the installer.

The current stack groups are:

- infra — core infrastructure services
- proxy — reverse proxy and TLS-related services
- network — networking-oriented services
- security — security services such as DNS or auth-related components
- media — media services

## Storage layout

The installer expects persistent data under /srv:

- /srv/docker
- /srv/media
- /srv/backups
- /srv/certificates
- /srv/jellyfin/config
- /srv/jellyfin/cache
- /srv/navidrome/data

## Security guidance

Do not commit or publish real secrets, credentials, private keys, or live networking details.

Examples of values that should be customized per deployment:

- hostnames
- usernames
- private IPs
- Tailscale addresses
- admin credentials
- API tokens
- TLS private keys

## When troubleshooting

If the installer or stack fails, start by checking:

1. whether the script is running as root or via sudo;
2. whether Docker is installed and running;
3. whether docker compose is available;
4. whether the required directories under /srv exist;
5. whether the compose files exist under /srv/docker/*/compose.yml;
6. whether the services themselves are healthy after deployment.

Useful commands:

```bash
bash -n install.sh
./install.sh --help
./install.sh --check
./install.sh --dry-run --verbose
sudo docker ps
sudo docker compose -f /srv/docker/infra/compose.yml config
```

## Notes for future AI assistance

When helping modify this repository, keep the following in mind:

- Preserve the current installer flow unless the user explicitly asks for a change.
- Do not hardcode personal values into the docs or config examples.
- Keep the documentation neutral and reusable.
- Prefer adding features that improve usability without breaking existing deployments.
