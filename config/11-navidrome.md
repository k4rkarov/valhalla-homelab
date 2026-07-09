# Navidrome

> Self-hosted music streaming server for **Valhalla**.

---

## Purpose

Navidrome manages and streams Valhalla's local music library.

It provides a streaming-like experience using locally stored files controlled by the administrator.

---

## Docker Compose

Location:

```text
config/docker-compose-stacks/media.yaml
```

Image:

```text
deluan/navidrome
```

Container:

```text
navidrome
```

---

## Structure

| Path | Purpose |
| --- | --- |
| `/srv/navidrome/data` | Database, playlists, users, and settings |
| `/srv/media/music` | Music library |

---

## Library Organization

Recommended pattern:

```text
/srv/media/music
├── Agalloch
│   └── The Mantle (2002)
│       ├── 01 - A Celebration for the Death of Man.flac
│       └── 02 - In the Shadow of Our Pale          Companion.flac
└── Dead Can Dance
    └── Within the Realm of a Dying Sun (1987)
```

Navidrome depends heavily on embedded metadata.

Important fields:

- Artist;
- Album Artist;
- Album;
- Track;
- Disc Number;
- Genre;
- Year.

---

## Supported Formats

Common formats:

- FLAC;
- MP3;
- AAC;
- OGG;
- OPUS;
- ALAC;
- WAV.

Prefer FLAC when possible for quality preservation.

---

## Access

| Type | Value |
| --- | --- |
| Internal | `http://navidrome:4533` |
| Published port | `4533` |
| Recommended domain | `https://music.valhalla` |
| Proxy Host | `navidrome` -> `4533` |
| DNS Rewrite | `music.valhalla` -> `192.168.1.50` |

The general access flow is documented in [`00-architecture.md`](00-architecture.md).

---

## Clients

Navidrome implements the Subsonic API.

Recommended clients:

| Platform | Clients |
| --- | --- |
| iPhone | Amperfy, play:Sub |
| Android | Symfonium, Ultrasonic |
| Desktop | Browser, Supersonic |

Server URL:

```text
https://music.valhalla
```

---

## Planned Library Profile

The music library is planned mainly around:

- Folk;
- Dark Folk;
- Neofolk;
- Atmospheric Black Metal;
- DSBM;
- Doom Metal;
- Post Metal;
- Ambient;
- Post Rock;
- Classical.

---

## Backup

Include in backups:

```text
/srv/navidrome/data
/srv/media/music
```

The first directory preserves the database, users, and playlists. The second preserves the music collection.

---

## Update

```bash
docker compose pull
docker compose up -d
```

The library remains preserved.

---

## Troubleshooting

### No music appears

Check:

- library path;
- permissions;
- Docker volume;
- supported files.

### Album split across several artists

This usually happens when `Album Artist` is not filled correctly.

### Covers do not appear

Check:

- embedded tags;
- `cover.jpg`;
- `folder.jpg`.

### Streaming does not work

Check:

- Proxy Host;
- port `4533`;
- DNS Rewrite;
- HTTPS.
