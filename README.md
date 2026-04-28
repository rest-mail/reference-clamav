# reference-clamav

A multi-arch [clamav](https://www.clamav.net/) container built on Alpine. Multi-arch (`linux/amd64` + `linux/arm64`), MIT-licensed, calver-tagged.

Built on `alpine:3.20 + apk add clamav` rather than wrapping `clamav/clamav` because the upstream Docker Hub image is amd64-only and breaks our multi-arch contract.

clamav is a stateless antivirus scanner — bytes in, infected/clean out. There's no per-tenant config, no learning, no reputation. This image exposes clamd on TCP `:3310`; consumers send file streams via the standard clamd protocol.

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

| Variable | Default | Description |
|----------|---------|-------------|
| `CLAMAV_FRESHCLAM` | `false` | Run the `freshclam` daemon in the background for periodic signature updates. The initial signature fetch always happens at first start regardless of this flag. |

The clamav engine itself is configured via `/etc/clamav/clamd.conf` and `/etc/clamav/freshclam.conf`. Override either by mounting a replacement at the same path:

```bash
docker run -v $(pwd)/clamd.conf:/etc/clamav/clamd.conf:ro \
  ghcr.io/rest-mail/reference-clamav:latest
```

## Healthcheck

```
echo PING | nc -w 2 127.0.0.1 3310 | grep -q PONG
```

`start-period` is 300s because the initial signature download takes 5–10 minutes on a fresh container; without signatures, clamd refuses to start.

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
