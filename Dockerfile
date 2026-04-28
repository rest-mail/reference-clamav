FROM alpine:3.20

# Alpine ships clamav for both amd64 and arm64 — unlike upstream
# clamav/clamav which is amd64-only and breaks our multi-arch contract.
RUN apk add --no-cache \
      clamav \
      clamav-libunrar \
      clamav-daemon \
      freshclam \
      netcat-openbsd \
      tini \
 && mkdir -p /var/lib/clamav /var/log/clamav /run/clamav \
 && chown -R clamav:clamav /var/lib/clamav /var/log/clamav /run/clamav

# Default config: log to stdout, listen on TCP 3310 on all interfaces.
RUN sed -i \
      -e 's|^#LogFile .*|LogFile /dev/stdout|' \
      -e 's|^#LogTime .*|LogTime yes|' \
      -e 's|^#PidFile .*|PidFile /run/clamav/clamd.pid|' \
      -e 's|^#TCPSocket .*|TCPSocket 3310|' \
      -e 's|^#TCPAddr .*|TCPAddr 0.0.0.0|' \
      -e 's|^#User .*|User clamav|' \
      -e 's|^Example|#Example|' \
      /etc/clamav/clamd.conf \
 && sed -i \
      -e 's|^#UpdateLogFile .*|UpdateLogFile /dev/stdout|' \
      -e 's|^#DatabaseOwner .*|DatabaseOwner clamav|' \
      -e 's|^#DatabaseDirectory .*|DatabaseDirectory /var/lib/clamav|' \
      -e 's|^Example|#Example|' \
      /etc/clamav/freshclam.conf

COPY --chmod=0755 entrypoint.sh /usr/local/bin/entrypoint.sh

EXPOSE 3310

HEALTHCHECK --interval=30s --timeout=10s --start-period=300s --retries=5 \
  CMD echo PING | nc -w 2 127.0.0.1 3310 | grep -q PONG || exit 1

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
