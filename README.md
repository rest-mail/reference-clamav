# reference-clamav

A thin convention-conforming wrapper around the upstream [`clamav/clamav`](https://hub.docker.com/r/clamav/clamav) image. Multi-arch (`linux/amd64` + `linux/arm64`), MIT-licensed, calver-tagged.

clamav is a stateless antivirus scanner — `bytes in, infected/clean out`. There's no per-tenant config, no learning, no reputation. The wrapper exists for tagging consistency and the rest-mail healthcheck convention; it does **not** add overlay config support because there's nothing meaningful to overlay.

## Image

```
ghcr.io/rest-mail/reference-clamav:latest          # always newest
ghcr.io/rest-mail/reference-clamav:YYYY.MM.DD      # immutable calver tag
```

## Quick start

```bash
docker run --rm -p 3310:3310 \
  ghcr.io/rest-mail/reference-clamav:latest
```

First boot downloads the virus signature database (~5–10 minutes). Watch with:

```bash
docker logs -f <container>
```

clamd listens on TCP `:3310` (the LDAP-style protocol). Use any clamav client library to send file streams for scanning.

## Environment variables

This image inherits all environment variables from upstream `clamav/clamav`. The relevant ones:

| Variable | Description |
|----------|-------------|
| `CLAMAV_NO_FRESHCLAMD` | `false` (default) runs `freshclam` daemon for signature updates; `true` disables it |
| `CLAMAV_NO_CLAMD` | `false` (default) runs `clamd`; `true` disables it (e.g. for one-shot scans) |
| `CLAMAV_NO_MILTERD` | `true` (default) disables milter; `false` enables |

See [upstream docs](https://docs.clamav.net/manual/Installing/Docker.html) for the full list.

## Healthcheck

```
clamdcheck.sh
```

The `start-period` is 120s because the initial signature download is slow. After that, `clamdcheck.sh` returns within a second.

## Why no overlay support?

The clamav engine is configured by `clamd.conf` and `freshclam.conf`. Both are reasonable out-of-the-box for any standard mail-scanning use case, and the upstream image already mounts them at well-known paths. Power users who genuinely need to tweak them can:

```bash
docker run -v $(pwd)/clamd.conf:/etc/clamav/clamd.conf:ro \
  ghcr.io/rest-mail/reference-clamav:latest
```

— same as with the upstream image. Adding our own `/etc/clamav-overlay/` indirection would be ceremony without value.

## License

MIT.

## See also

- [`rest-mail/conventions`](https://github.com/rest-mail/conventions) — the contract every `reference-*` image follows
- [`rest-mail/testbed`](https://github.com/rest-mail/testbed) — runs this image as a shared singleton on `mailnet`
