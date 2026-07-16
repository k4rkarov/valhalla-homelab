# Valhalla Homelab Roadmap

This document outlines the official roadmap for the **Valhalla Homelab** project, including completed milestones, planned improvements, and long-term goals. It serves as a reference for the project's evolution, with a focus on security, reliability, automation, documentation, and infrastructure reproducibility.

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
| Infrastructure Hardening | ⏳ Planned |
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

# Infrastructure Hardening

Planned improvements:

- Dedicated non-privileged service account for containerized services.
- Migration of infrastructure files to `/srv`.
- Docker hardening and privilege minimization.
- Container network segmentation.
- Restore and disaster recovery procedures.
- Periodic internal security assessments.
- Reduced attack surface for publicly exposed services.
- Future implementation of Docker rootless mode (if operationally viable).

The primary objective is to separate infrastructure management from day-to-day administration while minimizing the privileges required by services running on the host system.

---

# Infrastructure Layout

```text
/srv/

docker/
configs/
backups/
scripts/
security/
documentation/
```

Future Docker structure:

```text
/srv/docker/

compose/
volumes/
configs/
```

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
- Cloud storage? (Backblaze B2 or equivalent)

Objectives:

- Fast disaster recovery.
- Full infrastructure restoration.
- Backup versioning.
- Tested restore procedures.

---

# GitHub Repository

The GitHub repository will serve as the project's central source of documentation.

Remaining tasks:

- Final README.
- Updated screenshots.
- Infrastructure diagrams.
- Complete technical documentation.
- Version history.
- Releases.
- Changelog.

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

Future objectives:

- Automated updates.
- Infrastructure health checks.
- Backup validation.
- Service status reporting.
- Maintenance automation.

---

# Storage

Current configuration:

- Internal SSD.

Planned upgrades:

- Larger M.2 SSD.
- External HDD.
- NAS.
- RAID (if operationally required).

---

# Planned Services

The following applications may be added in the future:

- Immich
- Paperless-ngx
- Stirling PDF
- IT-Tools
- Excalidraw
- Dozzle
- File Browser
- RustDesk Server

New services will be added only when justified by operational needs.

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

Objectives:

- Maintain a persistent offensive security environment.
- Perform internal security assessments.
- Develop proof-of-concept exploits.
- Study network security and attack methodologies.
- Document findings and experiments.

---

# Certificates

Already implemented:

- Private Root Certificate Authority.
- Wildcard certificate (`*.valhalla`).
- CA deployment to trusted devices.

Future improvements:

- Automated certificate renewal.
- Complete issuance documentation.

---

# DNS

Implemented:

- AdGuard Home.
- DNS Rewrites.
- Split DNS.
- Tailscale integration.
- Tailscale Subnet Router.

Future improvements:

- DHCP via AdGuard Home.
- DNS-over-HTTPS (DoH).
- DNS-over-TLS (DoT).
- Multiple upstream resolvers.
- Automatic failover.

---

# Networking

Planned improvements:

- IoT VLAN.
- Guest VLAN.
- Server VLAN.
- Replace the ISP router with a more capable solution (MikroTik, UniFi, OPNsense or TP-Link AX23).
- Future network segmentation improvements.

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

- A mature Docker-based infrastructure.
- Fully functional internal DNS.
- HTTPS across all services.
- Private certificate authority.
- Centralized management through Portainer.
- Secure remote access via Tailscale.
- Tailscale Subnet Router.
- Complete technical documentation.
- Automated and tested backup procedures.
- Full disaster recovery documentation.
- Dedicated infrastructure directories under `/srv`.
- Infrastructure hardening and privilege separation.
- A dedicated and isolated offensive security environment.
- An isolated VPS dedicated exclusively to penetration testing activities.

---

# Long-Term Vision

Valhalla is more than a homelab. It is a personal infrastructure platform designed for continuous learning, automation, offensive and defensive security, self-hosting, and professional development.

The long-term objective is to maintain a modular, reproducible, well-documented, and resilient environment that can be fully rebuilt from the GitHub repository and versioned backups.

---

# Project Phases

## PHASE 1 - Infrastructure Consolidation (Current)

- [ ] Automated Backups.
- [ ] Complete Documentation.
- [ ] Administrative Scripts.
- [ ] Infrastructure Hardening.
- [ ] Restore Procedures Documentation.
- [ ] Disaster Recovery Procedures.
- [ ] Internal Pentesting Documentation.

---

## PHASE 2 - Infrastructure Improvements

- [ ] Dedicated non-privileged service account.
- [ ] Migration to `/srv`.
- [ ] Docker privilege minimization.
- [ ] Container network segmentation.
- [ ] DNS Improvements.
- [ ] Monitoring Improvements.

---

## PHASE 3 - Offensive Security Improvements

- [ ] Kali Linux Improvements.
- [ ] Pentesting Tooling Improvements.
- [ ] Internal Security Assessments.
- [ ] Offensive Security Environment Improvements.
- [ ] Isolated Pentest VPS.

---

## PHASE 4 - Additional Services

- [ ] Immich.
- [ ] Paperless-ngx.
- [ ] Stirling PDF.
- [ ] IT-Tools.
- [ ] Excalidraw.
- [ ] Dozzle.
- [ ] File Browser.
- [ ] RustDesk Server.

---

## PHASE 5 - Hardware Improvements

- [ ] TP-Link AX23.
- [ ] Larger M.2 SSD.
- [ ] NAS Integration.
- [ ] Proxmox Evaluation.
- [ ] Future VLAN Implementation.