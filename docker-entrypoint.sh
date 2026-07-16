#!/bin/sh
set -eu

mkdir -p /app/config

# Named volumes / bind mounts often arrive as root-owned. Fix ownership when we
# still have privileges, then drop to the fixed app user before starting Node.
if [ "$(id -u)" = "0" ]; then
  chown -R app:app /app/config
  exec su-exec app:app "$@"
fi

exec "$@"
