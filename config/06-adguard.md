# AdGuard Home

> Internal DNS server for the **Valhalla** infrastructure.

---

## Purpose

AdGuard Home provides DNS resolution for internal Valhalla services.

Although it also blocks ads, trackers, and malicious domains, its primary homelab role is friendly name resolution:

- `homepage.valhalla`
- `vault.valhalla`
- `music.valhalla`
- `karkaflix.valhalla`
- `status.valhalla`

The full flow between DNS, Tailscale, and Nginx Proxy Manager is documented in [`00-architecture.md`](00-architecture.md).

---

## Role

AdGuard resolves names. It does not forward HTTP traffic.

```text
Client
-> DNS query
-> AdGuard Home
-> 192.168.1.50
-> Nginx Proxy Manager
-> Application
```

---

## Docker Compose

Location:

```text
config/docker-compose-stacks/network.yaml
```

Image:

```text
adguard/adguardhome
```

Container:

```text
adguard-home
```

Named volumes:

```text
adguard-work
adguard-conf
```

---

## Ports

| Port | Protocol | Use |
| --- | --- | --- |
| `53` | TCP/UDP | DNS queries |
| `3002` | TCP | Local admin interface |

Access:

```text
http://192.168.1.50:3002
https://adguard.valhalla
```

---

## DNS Rewrites

Internal names point to the same server:

| Name | IP |
| --- | --- |
| `homepage.valhalla` | `192.168.1.50` |
| `vault.valhalla` | `192.168.1.50` |
| `music.valhalla` | `192.168.1.50` |
| `karkaflix.valhalla` | `192.168.1.50` |
| `adguard.valhalla` | `192.168.1.50` |
| `status.valhalla` | `192.168.1.50` |

This simplifies DNS, certificates, HTTPS, and documentation. Nginx Proxy Manager chooses the final destination based on the request host.

---

## Upstream DNS

Local `*.valhalla` queries are answered by AdGuard itself.

Public queries are forwarded to upstream resolvers such as:

- Cloudflare;
- Quad9;
- Google DNS.

---

## Domain Blocking

AdGuard can block:

- ads;
- trackers;
- malicious domains;
- telemetry;
- phishing.

Blocking happens at the DNS layer before TCP connections are opened.

---

## Tailscale Integration

Outside the local network, Tailscale uses Split DNS to send `valhalla` domain queries to AdGuard.

AdGuard still returns `192.168.1.50`; the Tailscale Subnet Router makes that IP reachable remotely.

Related settings:

- Split DNS for `valhalla`;
- AdGuard advertised as Tailnet DNS;
- route `192.168.1.0/24` approved in Tailscale.

---

## Backup

Include in backups:

```text
adguard-conf
adguard-work
```

These directories preserve:

- settings;
- DNS Rewrites;
- blocklists;
- clients;
- filters;
- logs;
- statistics.

---

## Troubleshooting

### DNS does not resolve

```bash
dig homepage.valhalla
nslookup homepage.valhalla
```

### Test AdGuard directly

```bash
dig @192.168.1.50 homepage.valhalla
nslookup homepage.valhalla 192.168.1.50
```

### Service works by IP but not by domain

Possible causes:

- missing DNS Rewrite;
- client using another DNS resolver;
- DNS cache;
- Tailscale DNS disabled.

### Does not work remotely

Check:

- Tailscale connection;
- MagicDNS;
- Split DNS;
- approved Subnet Router;
- announced `192.168.1.0/24` route.

### DNS port

```bash
sudo ss -tulpn | grep :53
```

---

## Operating Decision

Without AdGuard, services could still be reached by IP and port, but Valhalla would lose the consistent naming layer that works both locally and remotely.
