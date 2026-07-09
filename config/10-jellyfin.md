# Jellyfin

> Movies and series server for **Valhalla**, published as **Karkaflix**.

---

## Purpose

Jellyfin manages and streams Valhalla's local video library.

It organizes movies, series, metadata, posters, summaries, cast information, and subtitles without relying on proprietary services.

---

## Docker Compose

Location:

```text
config/docker-compose-stacks/media.yaml
```

Image:

```text
jellyfin/jellyfin
```

Container:

```text
jellyfin
```

---

## Structure

| Path | Purpose |
| --- | --- |
| `/srv/jellyfin/config` | Settings, users, and libraries |
| `/srv/jellyfin/cache` | Jellyfin cache |
| `/srv/media/movies` | Movies |
| `/srv/media/series` | Series |

The `/srv/media/music` directory exists under the same root, but is used by Navidrome.

---

## Library Organization

Movies:

```text
/srv/media/movies
└── Primer (2004)
    ├── Primer (2004).mp4
    └── Primer (2004).pt-BR.srt
```

Series:

```text
/srv/media/series
└── Pluribus
    └── Season 01
        ├── Pluribus S01E01.mkv
        ├── Pluribus S01E02.mkv
        └── Pluribus S01E03.mkv
```

Recommendations:

- one directory per movie;
- one folder per season;
- no release, codec, or group information in filenames;
- subtitles in the same directory as the video;
- `.srt` files encoded as UTF-8.

---

## Libraries

| Library | Path |
| --- | --- |
| Movies | `/srv/media/movies` |
| Series | `/srv/media/series` |

Each library has its own scanner.

---

## Access

| Type | Value |
| --- | --- |
| Internal | `http://jellyfin:8096` |
| Published port | `8096` |
| Recommended domain | `https://karkaflix.valhalla` |
| Proxy Host | `jellyfin` -> `8096` |
| DNS Rewrite | `karkaflix.valhalla` -> `192.168.1.50` |

The general access flow is documented in [`00-architecture.md`](00-architecture.md).

---

## Playback

Jellyfin supports:

- Direct Play;
- Direct Stream;
- Transcoding.

Prefer Direct Play whenever possible to reduce CPU usage.

---

## Backup

Include in backups:

```text
/srv/jellyfin/config
/srv/jellyfin/cache
/srv/media/movies
/srv/media/series
```

The `config` backup preserves users, libraries, and settings. The `/srv/media` backup preserves the media library.

---

## Update

```bash
docker compose pull
docker compose up -d
```

The library and settings remain preserved.

---

## Troubleshooting

### Movie does not appear

Check:

- directory structure;
- filename;
- correct library;
- read permissions.

Then run `Scan Library Files`.

### Series appears duplicated

This usually happens when episodes exist both in the library root and inside the season folder.

Each episode should exist only once.

### Subtitles do not appear

Check:

- `.srt` filename;
- same directory as the video;
- UTF-8 encoding.

### Incorrect metadata

Use `Identify` in Jellyfin and manually select the correct title.

### HTTPS does not work

Check:

- DNS Rewrite;
- Proxy Host;
- wildcard certificate;
- installed Root CA.
