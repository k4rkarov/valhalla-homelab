# Valhalla Homelab Roadmap

This document outlines the official roadmap for the **Valhalla Homelab** project, including completed milestones, planned improvements, and long-term goals. It serves as a reference for the project's evolution, with a focus on security, reliability, automation, and documentation.

---

# Overall Status

| Component | Status |
|-----------|--------|
| Debian Server | ✅ Completed |
| Docker | ✅ Completed |
| Portainer | ✅ Completed |
| Homepage | ✅ Completed |
| Nginx Proxy Manager | ✅ Completed |
| AdGuard Home | ✅ Completed |
| Vaultwarden | ✅ Completed |
| Jellyfin | ✅ Completed |
| Navidrome | ✅ Completed |
| Uptime Kuma | ✅ Completed |
| Kali Linux Lab | ✅ Completed |
| Internal HTTPS with Private CA | ✅ Completed |
| Internal DNS (`*.valhalla`) | ✅ Completed |
| Tailscale | ✅ Completed |
| Split DNS | ✅ Completed |
| Tailscale Subnet Router | ✅ Completed |
| Documentation | 🚧 In Progress |
| Automated Backups | ⏳ Planned |
| VPS Integration | ⏳ Planned |

---

# Upcoming Milestones

## VPS

A dedicated Virtual Private Server (VPS) is planned as a separate environment for penetration testing and security research.

Unlike the homelab infrastructure, the VPS will remain logically isolated and will **not** be used to expose internal services or provide external access to the local network.

Primary objectives:

- Host offensive security tooling.
- Deploy vulnerable applications for testing.
- Perform Internet-based security assessments.
- Execute proof-of-concept exploits in an isolated environment.
- Simulate real-world attack scenarios.

Keeping the VPS isolated ensures that experimentation and offensive activities remain completely independent from the production homelab while providing a realistic environment for professional security testing.

---

# Backup System

An automated backup solution is planned.

Directory structure:

```text
/srv/backups/

docker/
volumes/
configs/
databases/
certificates/
```

Services and data to be backed up:

- Nginx Proxy Manager
- AdGuard Home
- Vaultwarden
- Homepage
- Jellyfin
- Navidrome
- Portainer
- Docker Compose files
- TLS certificates
- Documentation

Backup destinations:

- External HDD
- NAS (future)
- Cloud storage (Backblaze B2 or equivalent)

Objectives:

- Fast disaster recovery
- Full infrastructure restoration
- Backup versioning

---

# GitHub Repository

The GitHub repository will serve as the project's central source of documentation.

Remaining tasks:

- Final README
- Updated screenshots
- Infrastructure diagrams
- Complete technical documentation
- Version history
- Releases
- Changelog

---

# Security

## CrowdSec

Planned to protect Nginx Proxy Manager.

Benefits:

- Automatic blocking of scanners
- Brute-force mitigation
- Shared threat intelligence
- Bot protection

---

## Fail2ban

May be introduced if additional services are exposed publicly.

---

## Wazuh

Potential SIEM integration.

Objectives:

- Centralized log monitoring
- Event correlation
- Auditing
- Incident detection

---

## Suricata

Potential IDS/IPS deployment for network monitoring.

---

# Observability

Netdata has been removed from the infrastructure.

If more advanced monitoring becomes necessary, the following stack may be adopted:

- Prometheus
- Grafana
- Loki
- Promtail

At the moment, operational monitoring is primarily performed through standard Linux tools and the command line.

---

# Automation

Administrative scripts will be developed to simplify routine maintenance.

Examples:

```text
update.sh
backup.sh
healthcheck.sh
docker-prune.sh
certificate-renew.sh
```

These scripts may later be scheduled using cron.

---

# Storage

Current configuration:

- Internal SSD

Planned upgrades:

- Larger M.2 SSD
- External HDD
- NAS
- RAID (if needed)

---

# Current Services

## Infrastructure

- Debian
- Docker
- Docker Compose
- Portainer
- Nginx Proxy Manager
- AdGuard Home
- Homepage
- Tailscale

## Security

- Vaultwarden
- Kali Linux

## Media

- Jellyfin
- Navidrome

## Monitoring

- Uptime Kuma

---

# Planned Services

The following applications may be added in the future:

- Forgejo
- Gitea
- Immich
- Paperless-ngx
- Stirling PDF
- IT-Tools
- Excalidraw
- Dozzle
- File Browser
- RustDesk Server

New services will be added based on operational needs.

---

# Pentesting Lab

With the addition of Kali Linux, Valhalla includes a dedicated environment for offensive security research and testing.

Planned directory structure:

```text
/srv/security/

workspace/
reports/
scans/
loot/
wordlists/
payloads/
exploits/
scripts/
tools/
recon/
```

Core tools:

- Nmap
- SQLMap
- Hydra
- Gobuster
- Nikto
- John the Ripper
- tcpdump
- curl
- Git

Possible future additions:

- nuclei
- ffuf
- httpx
- subfinder
- amass
- katana
- feroxbuster
- Burp Suite Community
- Metasploit Framework

The objective is to maintain a persistent and isolated environment for learning, proof-of-concept development, scripting, and security assessments.

---

# Certificates

Already implemented:

- Private Root Certificate Authority
- Wildcard certificate (`*.valhalla`)
- CA deployment to trusted devices

Future improvements:

- Automated certificate renewal
- Complete issuance documentation

---

# DNS

Implemented:

- AdGuard Home
- DNS Rewrites
- Split DNS
- Tailscale integration
- Tailscale Subnet Router

Future improvements:

- DHCP via AdGuard Home
- DNS-over-HTTPS (DoH)
- DNS-over-TLS (DoT)
- Multiple upstream resolvers
- Automatic failover

---

# Networking

Planned improvements:

- IoT VLAN
- Guest VLAN
- Server VLAN
- Replace the ISP router with a more capable solution (MikroTik, UniFi, or OPNsense)

---

# Documentation

Planned documentation:

```text
hardware.md
debian.md
docker.md
portainer.md
nginx.md
homepage.md
adguard.md
vaultwarden.md
jellyfin.md
navidrome.md
uptime-kuma.md
tailscale.md
dns.md
tls.md
networking.md
security.md
backup.md
maintenance.md
roadmap.md
faq.md
troubleshooting.md
```

---

# Version 1.0 Goals

Version 1.0 will be considered complete when the project includes:

- A mature Docker-based infrastructure
- Fully functional internal DNS
- HTTPS across all services
- Private certificate authority
- Centralized management through Portainer
- Secure remote access via Tailscale
- Tailscale Subnet Router
- Complete documentation
- Automated backup solution
- VPS integration

---

# Long-Term Vision

Valhalla is more than a homelab. It is a personal infrastructure platform designed for continuous learning, automation, offensive and defensive security, self-hosting, and professional development.

The long-term objective is to maintain a modular, reproducible, well-documented, and resilient environment that can be fully rebuilt from the GitHub repository and versioned backups.