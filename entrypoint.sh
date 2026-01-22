#!/usr/bin/env sh
set -eu

: "${BASIC_AUTH_USER:?Set BASIC_AUTH_USER}"
: "${BASIC_AUTH_PASS:?Set BASIC_AUTH_PASS}"

# Generate an htpasswd-compatible APR1 hash that nginx understands
HASH="$(openssl passwd -apr1 "$BASIC_AUTH_PASS")"
printf "%s:%s\n" "$BASIC_AUTH_USER" "$HASH" > /tmp/.htpasswd
chmod 644 /tmp/.htpasswd

# Start Langflow on an internal port
langflow run --host 0.0.0.0 --port 7861 &

# Run nginx in the foreground
exec nginx -g 'daemon off;'
