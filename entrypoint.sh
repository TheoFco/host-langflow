#!/usr/bin/env sh
set -eu

: "${BASIC_AUTH_USER:?Set BASIC_AUTH_USER}"
: "${BASIC_AUTH_PASS:?Set BASIC_AUTH_PASS}"

HASH="$(printf "%s" "$BASIC_AUTH_PASS" | openssl sha1 -binary | openssl base64)"
printf "%s:{SHA}%s\n" "$BASIC_AUTH_USER" "$HASH" > /etc/nginx/.htpasswd
chmod 600 /etc/nginx/.htpasswd

# Start Langflow on an internal port
langflow run --host 0.0.0.0 --port 7861 &

# Run nginx in the foreground
exec nginx -g 'daemon off;'
