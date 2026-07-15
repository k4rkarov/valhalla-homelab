# Debian

> Operating system for the **Valhalla** server.

---

## Purpose

Debian is the base layer of Valhalla. The host provides the system resources required by Docker, while applications run in containers.

Selection criteria:

- stability;
- low resource usage;
- long-term support;
- strong documentation;
- large community;
- Docker compatibility;
- easy recovery.

---

## Distribution

| Item | Value |
| --- | --- |
| Distribution | Debian GNU/Linux |
| Version | Debian 13 (Trixie) |
| Architecture | amd64 |

Check the kernel:

```bash
uname -r
```

---

## Installation Notes

The system was installed from the official Debian image.

XFCE was installed for local maintenance convenience, although the server is primarily administered through SSH. It can be removed later without affecting Docker services.

---

## Filesystem Layout

Simplified layout:

```text
/
├── /home
├── /srv
├── /var
├── /etc
└── /boot
```

Main paths:

| Path | Purpose |
| --- | --- |
| `/srv` | Docker data, media, certificates, backups |
| `/home` | User files |
| `/etc` | System configuration |
| `/var` | System and service runtime data |

---

## Administrative User

User:

```text
your-user
```

Daily administration uses:

```bash
sudo
```

Direct root SSH access remains disabled.

---

## Updates

```bash
sudo apt update
sudo apt full-upgrade
sudo apt autoremove
sudo apt autoclean
```

---

## Essential Packages

```bash
sudo apt install \
curl \
wget \
git \
vim \
htop \
btop \
tree \
ncdu \
zip \
unzip \
ca-certificates \
gnupg \
lsb-release \
software-properties-common
```

---

## SSH

Check status:

```bash
sudo systemctl status ssh
```

Enable and start:

```bash
sudo systemctl enable ssh
sudo systemctl start ssh
```

Authentication uses Ed25519 SSH keys.

Check local keys:

```bash
ls ~/.ssh
```

---

## Firewall

Firewall:

```text
UFW
```

Common rules:

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw status verbose
```

Because remote access is primarily handled through Tailscale, only a small set of ports needs to remain open.

---

## Timezone

Check:

```bash
timedatectl
```

Set:

```bash
sudo timedatectl set-timezone America/Sao_Paulo
```

---

## Hostname

Hostname:

```text
valhalla
```

Check or change:

```bash
hostnamectl
sudo hostnamectl set-hostname valhalla
```

---

## Network Checks

```bash
ip a
ip route
resolvectl status
cat /etc/resolv.conf
```

---

## Logs

```bash
journalctl
journalctl -b
journalctl -u docker
journalctl -f
```

---

## Monitoring Commands

```bash
top
btop
free -h
df -h
ncdu /
ps aux
ss -tulpn
```

---

## Service Management

```bash
sudo systemctl start <service>
sudo systemctl stop <service>
sudo systemctl restart <service>
sudo systemctl status <service>
sudo systemctl enable <service>
```

---

## Reboot and Shutdown

```bash
sudo reboot
sudo poweroff
```

---

## Recovery

In case of OS reinstall:

1. Install Debian.
2. Restore SSH access.
3. Install Docker.
4. Restore `/srv`.
5. Restore Portainer stacks.
6. Restore certificates.
7. Restore Tailscale.
8. Validate services.

Because services use Docker Compose and persistent directories, recovery should be predictable.

---

## Operating Philosophy

Debian is treated as infrastructure. Application logic belongs in containers, reducing coupling between the operating system and services.
