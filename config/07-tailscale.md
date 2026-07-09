# Tailscale

> WireGuard-based mesh VPN for secure remote access to **Valhalla**.

---

## Purpose

Tailscale allows remote access to the homelab without:

- opening router ports;
- manually configuring NAT;
- using DDNS;
- exposing services directly to the Internet.

In Valhalla, Tailscale is the only remote access path.

---

## Role

Tailscale connects authorized devices in a private network called a Tailnet.

```text
MacBook
iPhone
Notebook
   |
Tailnet
   |
Valhalla
```

The full design with DNS, NPM, and HTTPS is documented in [`00-architecture.md`](00-architecture.md).

---

## Installation

On Debian:

```bash
curl -fsSL https://tailscale.com/install.sh | sh
```

Start and authenticate:

```bash
sudo tailscale up
```

---

## Server Address

Valhalla receives a stable Tailnet IP, for example:

```text
100.127.100.50
```

This address can be used for direct administration, while homelab services remain published through `*.valhalla`.

---

## MagicDNS

MagicDNS allows Tailnet devices to be reached by name, such as:

```text
valhalla
```

It is useful for administration, but internal services use the private `valhalla` domain resolved by AdGuard Home.

---

## Split DNS

Split DNS is configured for:

```text
valhalla
```

Only queries like these are sent to AdGuard:

- `homepage.valhalla`;
- `vault.valhalla`;
- `music.valhalla`;
- `karkaflix.valhalla`;
- `status.valhalla`.

Public queries continue using the normal system resolvers.

---

## Tailnet DNS

AdGuard Home is advertised as the Tailnet DNS resolver.

Server:

```text
100.127.100.50
```

Domain:

```text
valhalla
```

Tailscale-connected devices can then resolve internal domains automatically.

---

## Subnet Router

Valhalla advertises the local network:

```text
192.168.1.0/24
```

Command:

```bash
sudo tailscale up --advertise-routes=192.168.1.0/24
```

The route must be approved in the Tailscale admin panel.

This keeps DNS Rewrites pointing to `192.168.1.50` both locally and remotely.

---

## Exit Node

Valhalla is not configured as an Exit Node.

The goal is homelab access, not routing all client Internet traffic.

If needed later:

```bash
sudo tailscale up --advertise-exit-node
```

---

## SSH

Local network or Subnet Router:

```bash
ssh your-user@192.168.1.50
```

Direct Tailnet IP:

```bash
ssh your-user@100.127.100.50
```

---

## Useful Commands

```bash
tailscale status
tailscale ip
tailscale debug prefs
tailscale ping valhalla
sudo tailscale up
sudo tailscale up --advertise-routes=192.168.1.0/24
```

---

## Troubleshooting

### DNS does not work

Check:

- Tailscale connection;
- MagicDNS;
- Split DNS;
- AdGuard reachability.

### Domain resolves but does not open remotely

Check:

- approved route;
- active Subnet Router;
- Valhalla online;
- local firewall.

### Services work by IP but not by domain

Usually indicates:

- missing DNS Rewrite;
- client using another DNS resolver;
- DNS cache.

### Connectivity

```bash
ping 100.127.100.50
tailscale ping valhalla
```

---

## Decisions

- Tailscale as the private VPN.
- Split DNS for `valhalla`.
- AdGuard Home as Tailnet DNS.
- Subnet Router for `192.168.1.0/24`.
- No Exit Node by default.
- No public exposed ports.
