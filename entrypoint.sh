#!/bin/sh
set -eu

# Initial signature download if the database is empty. freshclam wants
# DatabaseDirectory writable; we set ownership in the Dockerfile.
if [ -z "$(ls -A /var/lib/clamav 2>/dev/null || true)" ]; then
  echo "[clamav] no signature database; running freshclam (this can take 5–10 minutes)..."
  su -s /bin/sh clamav -c freshclam || {
    echo "[clamav] freshclam failed; clamd will not start without a signature database" >&2
    exit 1
  }
fi

# Optional: continue running freshclam in the background for signature updates.
# Disabled by default — set CLAMAV_FRESHCLAM=true to enable.
if [ "${CLAMAV_FRESHCLAM:-false}" = "true" ]; then
  echo "[clamav] starting freshclam daemon for periodic signature updates..."
  su -s /bin/sh clamav -c "freshclam -d --foreground=false" &
fi

# Hand off to clamd as PID 1 (well, PID 1 is tini per Dockerfile).
exec clamd --foreground=true
