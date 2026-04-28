FROM clamav/clamav:stable

EXPOSE 3310

# clamav image's own healthcheck is fine, but we set ours explicitly to follow
# the rest-mail convention of every reference image declaring HEALTHCHECK.
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=5 \
  CMD clamdcheck.sh || exit 1
