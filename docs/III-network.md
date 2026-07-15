# Networking

## Overview

The Valhalla Homelab uses AdGuard Home as the primary DNS server and
Nginx Proxy Manager as the internal reverse proxy for all services.

```
                Internet
                    |
              Vivo Fiber Router
           (RTF8225VW-SV - REV4)
                    |
          -------------------------
          |                       |
      IPv4 DHCP               IPv6 SLAAC
          |                       |
      192.168.15.0/24         2804:xxxx::/64
          |                       |
      AdGuard Home             Clients
    (192.168.1.50)               |
          |                      |
     DNS Rewrites            iPhone/iPad
      *.valhalla                 |
          |                      |
   Nginx Proxy Manager       Prefer IPv6
          |
      Docker Services
          |
------------------------------------------------
|       |           |          |                |
Homepage Vaultwarden Jellyfin Navidrome     etc.
------------------------------------------------
```

---

## Router Information

| Property | Value |
|---------|---------|
| ISP | Vivo Fibra |
| Manufacturer | Askey |
| Model | RTF8225VW-SV |
| Hardware Revision | REV4 |
| Software Version | BR_SG_g2.5_RTF_TEF004_V3.9 |
| LAN Network | 192.168.15.0/24 |
| Valhalla IP Address | 192.168.1.50 |
| DNS Primary | 192.168.1.50 |
| DNS Secondary | 1.1.1.1 |

### Current Limitations

The ISP router presents several limitations:

- No DHCPv6 configuration options.
- No support for advertising custom IPv6 DNS servers.
- Limited DNS configuration capabilities.
- IPv6 configuration is automatically managed by the router.
- Clients receive IPv6 addresses through SLAAC.

Because of these limitations, IPv6 DNS configuration cannot currently be customized from the router.

---

## DNS Architecture

The current DNS flow is:

```
Client
   |
   |
AdGuard Home
192.168.1.50
   |
   +------------+
   |             |
DNS Rewrites    Upstream DNS
*.valhalla      Cloudflare
   |             |
192.168.1.50    1.1.1.1
   |
Nginx Proxy Manager
   |
Docker Services
```

All internal services resolve to:

```
192.168.1.50
```

---

## Static IP Reservation and Internal DNS Strategy

A stable IP address is a fundamental requirement for any server running infrastructure services.
The Valhalla server uses a DHCP reservation configured on the router, ensuring that the same IP address is always assigned to the same network interface. This approach provides the benefits of a static IP while keeping network management centralized through the router's DHCP service.
A fixed IP is required because several services depend on predictable addressing, including:

- AdGuard Home
- Internal DNS records
- Nginx Proxy Manager
- Docker services
- HTTPS certificates
- Local service discovery

Enter on the router's DHCP settings and create a reservation for the Valhalla server's MAC address:

| Hostname | MAC Address | IP Address |
| --- | --- | --- |
| `valhalla` | `ee:ab:2b:9c:e4:0b` | `192.168.1.50` |

Without a reserved IP, the server address could change after a reboot or DHCP lease renewal, causing service disruptions and requiring manual updates across the environment.

---

## IPv6 Investigation

### Server

The Valhalla server correctly receives IPv6 addresses:

```
2804:7f1:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx
```

AdGuard Home is correctly listening on IPv6.

The IPv6 routing table is also properly configured and the server is reachable through ICMPv6.

### Findings

The following tests were successful:

- IPv6 connectivity.
- ICMPv6.
- AdGuard Home listening on IPv6.
- Internal DNS rewrites.
- IPv4 DNS resolution.
- Android clients using automatic DNS configuration.

The following limitations were identified:

- No DHCPv6 support from the ISP router.
- No IPv6 DNS advertisement customization.
- Internal services currently only provide IPv4 DNS rewrites.

---

## iPhone Investigation

An extensive investigation was performed after iPhone devices were unable to resolve internal services while Android devices worked correctly.

### Symptoms

The iPhone was able to:

- Access the Internet.
- Reach public websites.
- Resolve some Apple domains.

The iPhone was NOT able to:

- Resolve *.valhalla domains.
- Access internal services through automatic DNS configuration.

### Root Cause

The problem was identified as IPv6 preference behavior.

The iPhone prioritizes IPv6 whenever it is available. Since:

- the router advertises IPv6,
- IPv6 DNS configuration cannot be customized,
- AdGuard Home is only advertised through IPv4,

the iPhone bypasses the expected DNS configuration when using automatic settings.

### Tests Performed

Successful tests:

- Disabling Tailscale.
- Disabling Limit IP Address Tracking.
- Multiple DNS cache flushes.
- Query Log inspection.
- IPv6 connectivity tests.
- Manual DNS configuration.
- Android client testing.

Results:

| Configuration | Result |
|-------------|--------|
| Automatic DNS | Failed |
| Manual DNS (192.168.1.50) | Works |
| Android + Automatic DNS | Works |
| macOS + Automatic DNS | Unchecked |
| iPhone + Automatic DNS | Failed |
| iPhone + Manual DNS | Works |

The issue is therefore specific to the interaction between:

- iOS,
- IPv6 preference,
- the Vivo router limitations.

---

## Workaround

For iPhone devices there are currently two options:

### Manual DNS

```
192.168.1.50
```

Advantages:

- Internal services work properly.

Disadvantages:

- Internet access is lost if Valhalla is powered off.

### Automatic DNS

Advantages:

- Internet always works.

Disadvantages:

- Internal *.valhalla services are unavailable.

---

## Future Improvements

Planned upgrades include:

- Maybe get a better router like TP-Link AX23