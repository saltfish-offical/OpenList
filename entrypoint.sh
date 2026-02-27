#!/bin/sh
set -e
DATA_DIR="/opt/openlist/data"
mkdir -p "$DATA_DIR"
if [ "$(id -u)" = "0" ]; then
    chown -R 1001:1001 "$DATA_DIR"
    find "$DATA_DIR" -type d -exec chmod 755 {} \;
    find "$DATA_DIR" -type f -exec chmod 644 {} \;
    exec su-exec 1001:1001 "$@"
else
    exec "$@"
fi
