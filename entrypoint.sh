#!/usr/bin/env sh
set -eu

: "${BASIC_AUTH_USER:?Set BASIC_AUTH_USER}"
: "${BASIC_AUTH_PASS:?Set BASIC_AUTH_PASS}"

HASH="$(printf "%s" "$BASIC_AUTH_PASS" | openssl sha1 -binary | openssl base64)"
printf "%s:{SHA}%s\n" "$BASIC_AUTH_USER" "$HASH" > /tmp/.htpasswd

# readable by nginx worker user
chmod 644 /tmp/.htpasswd

langflow run --host 0.0.0.0 --port 7861 &

exec nginx -g 'daemon off;'
