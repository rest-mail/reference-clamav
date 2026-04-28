#!/usr/bin/env bash
# Minimal smoke test: build, run, wait for clamd to be reachable on :3310.
# We don't wait for the full freshclam download (5-10 min) — just verify the
# image starts and clamd binds to its port.
set -euo pipefail

IMAGE="${IMAGE:-reference-clamav:smoke}"
PORT="${PORT:-23310}"
NAME="reference-clamav-smoke"

cleanup() {
  docker rm -f "$NAME" >/dev/null 2>&1 || true
}
trap cleanup EXIT

docker build -t "$IMAGE" .
docker run -d --rm --name "$NAME" -p "$PORT:3310" \
  -e CLAMAV_NO_FRESHCLAMD=true \
  "$IMAGE"

# Wait up to 60s for clamd to start binding.
for i in $(seq 1 60); do
  if docker exec "$NAME" sh -c 'echo PING | nc -w 1 127.0.0.1 3310 2>/dev/null | grep -q PONG'; then
    echo "OK: clamd answered PING"
    exit 0
  fi
  sleep 1
done

echo "FAIL: clamd did not respond to PING within 60s"
docker logs "$NAME" 2>&1 | tail -30
exit 1
