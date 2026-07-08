<h3 align="center">⚔️ VALHALLA ⚔️</h3>
<h1 align="center"> <img src="/images/valhalla-architecture.png" alt="Valhalla architecture"></h1>



A secure, self-hosted homelab built around privacy, simplicity and complete infrastructure ownership.

⸻

## Overview

Valhalla is my personal homelab, designed from the ground up as a private cloud, media server, password manager, DNS server, reverse proxy and experimentation environment.

Unlike traditional cloud-centric deployments, Valhalla follows a self-hosting first philosophy:

* No public services unless absolutely necessary.
* No exposed ports to the Internet.
* Secure remote access through Tailscale.
* Infrastructure entirely containerized with Docker.
* All services available through friendly DNS names.
* Centralized HTTPS using an internal PKI.

The objective is to own every layer of the stack while keeping deployment, maintenance and recovery as simple as possible.

⸻

## Design Philosophy

Valhalla was designed around five principles.

### Privacy

Every critical service runs locally.

Passwords, media, DNS, authentication and personal data never leave the infrastructure unless explicitly synchronized.

⸻

### Simplicity

The architecture intentionally avoids unnecessary complexity.

Instead of Kubernetes, multiple virtual machines or service meshes, the project relies on:

* Debian
* Docker Compose
* Docker volumes
* Reverse Proxy
* Private DNS

This keeps maintenance predictable while remaining extremely powerful.



### Security

Security is based on reducing attack surface rather than exposing services behind complex firewalls.

Key principles include:

* No public ports
* No port forwarding
* VPN-first architecture
* HTTPS everywhere
* Internal Certificate Authority
* Strong passwords
* SSH key authentication


## Modularity

Every application lives inside its own Docker container. 
New services can be added without affecting existing ones.
Infrastructure components remain independent.


## Hardware

Server Name: Valhalla

### Hardware

* CHUWI LarkBox
* Intel Celeron J4115
* 6 GB RAM
* 128 GB eMMC flash (system)
* 1 TB external HDD (storage)

The server runs 24/7 and hosts every self-hosted application.


### Operating System

* Debian Linux
* Docker Engine
* Docker Compose

The host system is intentionally minimal. Every application runs inside containers.


## High Level Architecture

```
        Internet
            │
            │
      Tailscale VPN
            │
            ▼
+----------------------+
|      VALHALLA        |
|                      |
|  Docker Engine       |
|                      |
|  ┌───────────────┐   |
|  │ Nginx Proxy   │   |
|  └──────┬────────┘   |
|         │            |
| ┌───────┼──────────┐ |
| │       │          │ |
| | docker services  │ |
+----------------------+
```

Every request enters through Nginx Proxy Manager, which terminates HTTPS and routes traffic according to the Host header.


## Network Architecture

Remote access is provided exclusively by Tailscale. No services are directly exposed to the Internet.

```
Mac / iPhone/ iPad / Laptop
            │
            ▼
    Tailscale Mesh VPN
            │
            ▼
         Valhalla
````

This architecture provides:

* encrypted communication
* automatic NAT traversal
* secure authentication
* zero exposed ports

## DNS Architecture

DNS is provided by AdGuard Home.

Instead of remembering IP addresses, every service has its own hostname.

Examples:

homepage.valhalla
vault.valhalla
karkafy.valhalla
karkaflix.valhalla
adguard.valhalla
portainer.valhalla

DNS rewrites map each hostname to the Valhalla server. 
When connected through Tailscale, the same hostnames work from anywhere in the world.

## HTTPS

Valhalla uses a private PKI.

Components:

* Root Certificate Authority
* Wildcard certificate (*.valhalla)
* Nginx Proxy Manager

Flow:

```
Client
↓
HTTPS
↓
Nginx Proxy Manager
↓
Wildcard Certificate
↓
Internal Service
```

This allows every internal service to use HTTPS without obtaining public certificates.


## Reverse Proxy

Nginx Proxy Manager provides:

* Reverse Proxy
* TLS termination
* Host routing
* Central certificate management

Instead of exposing container ports, every service is published through HTTPS.

Example:

```
https://vault.valhalla
↓
Vaultwarden
```


## Infrastructure Services

### Homepage

Landing page for the entire infrastructure.
Provides quick access to every service.


### Portainer

Container management interface.

Responsibilities:

* Docker stack deployment
* Logs
* Images
* Networks
* Volumes
* Updates

### AdGuard Home

Responsible for:

* Internal DNS
* DNS rewrites
* Ad blocking
* Malware filtering

### Nginx Proxy Manager

Provides

* HTTPS
* Reverse Proxy
* Certificate management

## Productivity

### Vaultwarden

Password manager compatible with Bitwarden.

Stores:

* passwords
* secure notes
* identities
* TOTP secrets

Entirely self-hosted.

## Media Stack

### Jellyfin (Karkaflix)

Purpose:

Personal Netflix replacement.


### Navidrome (Karkafly)

Personal music streaming server.
Streams music collection from anywhere.

Compatible with:

* Symfonium
* Amperfy
* Tempo
* Substreamer

## Storage

Media is stored separately from containers.

/srv/media
    movies/
    series/
    music/

Containers never contain user data.

Docker volumes only store application configuration.

## Docker Philosophy

Applications are grouped by purpose. Examples:

```
Infrastructure
Media
Utilities
````

Future services can be deployed independently.


## Security Model

Valhalla intentionally avoids exposing services publicly.

Security is based on:

* Tailscale authentication
* WireGuard encryption
* Private DNS
* HTTPS
* Internal CA
* SSH keys
* No public ports

## Why Not Cloud?

Because data ownership matters. Every important service is under complete control. No subscriptions. No monthly fees. No telemetry. No dependency on third-party providers (also because the whole valhala's *raison d'être* is the creation of the project in itself).

## Future Roadmap

Planned improvements include:

* VPS integration
* Automated backups
* Infrastructure monitoring
* GitHub Actions deployment
* Infrastructure as Code
* Automated certificate renewal
* Documentation website
* Secret management improvements

## Technology Stack (for now)


|Component|Purpose|
|----|----|
|Debian	|Operating System|
|Docker	|Container Runtime|
|Docker |Compose	Orchestration|
|Portainer	|Container Management|
|Nginx Proxy Manager|	Reverse Proxy|
|AdGuard Home	|DNS|
|Tailscale	|VPN|
|Homepage	|Dashboard|
|Vaultwarden|	Password Manager|
|Jellyfin (karkaflix)	|Media Server|
|Navidrome (karkafy)	|Music Server|

## Goals

Valhalla is an evolving infrastructure platform. A place to learn, experiment, self-host and maintain complete ownership over personal digital services.

The project will continue to evolve as new services, automation and infrastructure components are added.