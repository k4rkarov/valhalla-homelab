# Hardware

> Physical infrastructure documentation for the **Valhalla** homelab.

---

## Purpose

This document describes the hardware, storage, local network, and planned physical expansions used by Valhalla.

---

## Minimum Specs

The homelab can be kept intentionally small. The minimum practical hardware for this stack is:

- 64-bit Linux host;
- 2 CPU cores;
- 2 GB RAM, with 4 GB recommended;
- 16 GB of storage for the OS and Docker layer, preferably SSD-based;
- 1 Gbps network interface or better;
- external storage for media and backups if you plan to host large libraries.

This setup can run on a Raspberry Pi 4 or 5, a small mini PC, a NUC, or an old desktop. A Pi is suitable for the lighter pieces of the stack, such as DNS, reverse proxy, dashboarding, passwords, and monitoring. Media services like Jellyfin become more comfortable on a device with more RAM and faster storage, so a mini PC or NUC is usually the better long-term choice.

## Main Server

| Item | Value |
| --- | --- |
| Hostname | `valhalla` |
| Operating system | Debian 13 (Trixie) |
| Role | Docker host for the homelab services |

All Docker containers run on this machine.

---

## Hardware choice and its specs

<p align=center><img src="../images/larkbox.png" width="50%"></p>

| Item | Specification |
| --- | --- |
| Model | CHUWI LarkBox |
| CPU | Intel Celeron J4115 |
| Architecture | x86_64 |
| Memory | 6 GB DDR4 |
| Internal disk | 128 GB eMMC |
| Expansion | M.2 SSD slot |
| Network | Gigabit Ethernet |
| Wi-Fi | Integrated |

---

## Services Hosted

Currently hosted:

- Docker Engine;
- Docker Compose;
- Portainer;
- Nginx Proxy Manager;
- Homepage;
- AdGuard Home;
- Vaultwarden;
- Jellyfin;
- Navidrome;
- Uptime Kuma;
- Tailscale.

Potential future services:

- Grafana;
- Loki;
- Prometheus;
- Paperless-ngx;
- Immich;
- VPS tunnel.

---

## Storage Layout

Current base structure:

```text
/
└── srv
    ├── docker
    ├── media
    ├── backups
    └── certificates
```

Media layout:

```text
/srv/media
├── movies
├── series
└── music
```

---

## Planned Storage Expansion

A dedicated M.2 SSD (or HDD) is planned for:

- Jellyfin media;
- Navidrome music;
- backups;
- snapshots.

Goals:

- better performance;
- less wear on eMMC storage;
- easier migration.

---

## Local Network

| Item | Value |
| --- | --- |
| Network | `192.168.1.0/24` |
| Gateway | `192.168.1.1` |
| Server IP | `192.168.1.50` |
| Internal DNS | AdGuard Home |

---

## Tailnet

The server is part of a Tailscale Tailnet.

Main uses:

- remote administration;
- SSH;
- remote DNS;
- Subnet Router;
- private HTTPS access.

Valhalla advertises:

```text
192.168.1.0/24
```

This lets Tailscale clients access local network services while away from home.

---

## Power

The server is intended to run continuously.

Goals:

- high availability;
- continuous synchronization;
- media access at any time.

Future recommendation:

- add a UPS to protect against outages and abrupt shutdowns.

---

## Administration

Valhalla is administered through:

- SSH;
- Portainer;
- Homepage;
- Tailscale SSH, if enabled.

Daily administration is primarily done from the Linux terminal. Web interfaces are used when they make routine tasks easier.

---

## Monitoring

Basic host checks:

```bash
top
free -h
df -h
sensors
docker ps
docker stats
ss -tulpn
journalctl
```

Service availability is monitored by Uptime Kuma.

---

## Hardware Philosophy

The hardware strategy favors:

- simplicity;
- low power usage;
- high availability;
- easy recovery;
- complete documentation;
- minimal maintenance;
- free and open source software when possible.

---

## Roadmap

- Dedicated NVMe SSD;
- UPS;
- second backup server;
- VPS access layer;
- automated backups;
- periodic snapshots;
- distributed monitoring.
