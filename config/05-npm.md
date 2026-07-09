# Nginx Proxy Manager

> Reverse proxy, TLS termination, and central entry point for **Valhalla** applications.

---

## Purpose

Nginx Proxy Manager (NPM) publishes internal services with friendly names and HTTPS, so users do not need to remember ports.

Examples:

- `homepage.valhalla`
- `vault.valhalla`
- `portainer.valhalla`
- `karkaflix.valhalla`
- `music.valhalla`
- `adguard.valhalla`
- `status.valhalla`

The full DNS, Tailscale, and HTTPS design is documented in [`00-architecture.md`](00-architecture.md).

---

## Role

NPM receives HTTP/HTTPS connections and forwards each request to the correct container based on the requested host.

```text
Client
-> https://homepage.valhalla
-> Nginx Proxy Manager
-> homepage:3000
```

User-facing applications should be accessed through Proxy Hosts.

---

## Why NPM

Alternatives considered included Traefik, Caddy, raw Nginx, and HAProxy.

NPM was chosen because it provides:

- a simple web interface;
- custom certificate support;
- Let's Encrypt support if needed later;
- multiple Proxy Hosts;
- redirects;
- Access Lists;
- Custom Nginx Configuration;
- centralized management.

---

## Docker Compose

Location:

```text
config/docker-compose-stacks/proxy.yaml
```

Image:

```text
jc21/nginx-proxy-manager
```

Container:

```text
nginx-proxy-manager
```

Published ports:

| Port | Use |
| --- | --- |
| `80` | HTTP, redirects, compatibility |
| `81` | Admin panel |
| `443` | HTTPS applications |

---

## Data Structure

Named volumes:

```text
npm-data
npm-letsencrypt
```

They preserve users, hosts, certificates, internal database, and settings.

---

## Proxy Hosts

| Domain | Forward Host | Port | Scheme |
| --- | --- | --- | --- |
| `homepage.valhalla` | `homepage` | `3000` | HTTP |
| `vault.valhalla` | `vaultwarden` | `80` | HTTP |
| `karkaflix.valhalla` | `jellyfin` | `8096` | HTTP |
| `music.valhalla` | `navidrome` | `4533` | HTTP |
| `adguard.valhalla` | `adguard-home` | `3002` | HTTP |
| `status.valhalla` | `uptime-kuma` | `3001` | HTTP |

Common options:

- Block Common Exploits;
- Websockets Support;
- HTTP/2 Support.

---

## Certificates

Valhalla uses a private PKI.

| Item | Value |
| --- | --- |
| CA | `Valhalla Root CA` |
| Certificate | `*.valhalla` |
| SANs | `*.valhalla`, `valhalla` |

All Proxy Hosts use the same wildcard certificate.

Import flow:

1. Open `SSL Certificates`.
2. Select `Add SSL Certificate`.
3. Select `Custom`.
4. Import `wildcard.valhalla.crt`.
5. Import `wildcard.valhalla.key`.

Because the certificate is internal, it is not automatically renewed through Let's Encrypt. When it is near expiration, issue a new wildcard certificate, import it in NPM, and assign it to the Proxy Hosts.

---

## Backup

Include in backups:

```text
npm-data
npm-letsencrypt
```

These directories preserve:

- users;
- Proxy Hosts;
- certificates;
- settings;
- internal SQLite database.

---

## Troubleshooting

### `ERR_CERT_AUTHORITY_INVALID`

The Root CA is not installed or trusted on the client device.

Check:

- `Valhalla Root CA` installation;
- wildcard certificate validity;
- certificate SANs.

### Timeout

Usually indicates:

- incorrect Proxy Host;
- stopped container;
- wrong port;
- DNS conflict.

### Bad Gateway 502

NPM received the request but could not reach the application.

Check:

- running container;
- container name;
- internal port;
- shared Docker network.

### Domain does not resolve

The problem is likely DNS, not NPM.

```bash
dig homepage.valhalla
nslookup homepage.valhalla
```

---

## Useful Commands

```bash
docker logs -f nginx-proxy-manager
docker exec -it nginx-proxy-manager bash
dig homepage.valhalla
openssl s_client -connect homepage.valhalla:443
sudo ss -tulpn
```

---

## New Service Procedure

1. Create the container.
2. Validate internal access.
3. Create a DNS Rewrite in AdGuard.
4. Create a Proxy Host in NPM.
5. Attach the `*.valhalla` certificate.
6. Validate HTTPS through the domain.
7. Add the service to Homepage.
8. Add a monitor in Uptime Kuma.
