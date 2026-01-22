#!/usr/bin/env sh
set -eu

: "${BASIC_AUTH_USER:?Set BASIC_AUTH_USER}"
: "${BASIC_AUTH_PASS:?Set BASIC_AUTH_PASS}"

# Create htpasswd file in a writable location. Use bcrypt (nginx-compatible).
# Requires: apache2-utils (htpasswd) installed in the image.
htpasswd -Bbc /tmp/.htpasswd "$BASIC_AUTH_USER" "$BASIC_AUTH_PASS"
chmod 644 /tmp/.htpasswd

# Normalize DB URL if your platform injects postgres:// (Langflow expects postgresql://)
if [ "${LANGFLOW_DATABASE_URL:-}" != "" ]; then
  export LANGFLOW_DATABASE_URL="$(echo "$LANGFLOW_DATABASE_URL" | sed 's/^postgres:\/\//postgresql:\/\//')"
fi
# Some Langflow versions read DATABASE_URL; keep them in sync
if [ "${DATABASE_URL:-}" = "" ] && [ "${LANGFLOW_DATABASE_URL:-}" != "" ]; then
  export DATABASE_URL="$LANGFLOW_DATABASE_URL"
fi

# Start Langflow on an internal port that nginx will proxy to
langflow run --host 0.0.0.0 --port 7861 &
LANGFLOW_PID=$!

# Wait until Langflow is actually listening before starting nginx.
# This avoids early /health proxy failures and reduces restart flapping.
python3 - <<'PY'
import socket, time, sys
deadline = time.time() + 170  # keep < your 180s ECS grace period
while time.time() < deadline:
    try:
        s = socket.create_connection(("127.0.0.1", 7861), timeout=1)
        s.close()
        sys.exit(0)
    except OSError:
        time.sleep(0.5)
print("Langflow did not start listening on 7861 before deadline", file=sys.stderr)
sys.exit(1)
PY

# If langflow dies, shut down nginx too (and let ECS restart the task)
( wait "$LANGFLOW_PID" ) &

# Run nginx in foreground
exec nginx -g 'daemon off;'
