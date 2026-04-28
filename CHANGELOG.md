# Changelog

Calver-tagged. Newest on top.

## 2026.04.28

- Initial release.
- Wraps upstream `clamav/clamav:stable`. clamav itself is stateless — no overlay config, no env vars beyond what upstream provides. The wrapper exists for tagging consistency, multi-arch publish, and the rest-mail healthcheck convention.
- Multi-arch publish: linux/amd64, linux/arm64.
