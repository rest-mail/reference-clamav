# Changelog

Calver-tagged. Newest on top.

## 2026.04.28.2

- Switch base from `clamav/clamav:stable` to `alpine:3.20 + apk add clamav`.
  Reason: upstream `clamav/clamav` is amd64-only on Docker Hub; building on
  Alpine gives us multi-arch (amd64 + arm64) without depending on a third party.
- Add `CLAMAV_FRESHCLAM=true` env var to enable the freshclam signature-update
  daemon (off by default; the entrypoint always does the initial fetch).
- Healthcheck switched to a `PING/PONG` probe via netcat — works without the
  upstream image's `clamdcheck.sh` helper.

## 2026.04.28

- Initial release (yanked — amd64-only because of upstream image).
