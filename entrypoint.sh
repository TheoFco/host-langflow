#!/usr/bin/env sh
set -eu

# Required for the cookie-gated /__login_submit check in nginx.conf
: "${APP_PASSWORD:?Set APP_PASSWORD in Flightcontrol env vars}"

# Normalize DB URL scheme if needed
if [ "${LANGFLOW_DATABASE_URL:-}" != "" ]; then
  export LANGFLOW_DATABASE_URL="$(echo "$LANGFLOW_DATABASE_URL" | sed 's/^postgres:\/\//postgresql:\/\//')"
fi
if [ "${DATABASE_URL:-}" = "" ] && [ "${LANGFLOW_DATABASE_URL:-}" != "" ]; then
  export DATABASE_URL="$LANGFLOW_DATABASE_URL"
fi

# Start Langflow behind nginx on an internal port
LANGFLOW_PORT="${LANGFLOW_PORT:-7861}"
langflow run --host 0.0.0.0 --port "$LANGFLOW_PORT" &
LANGFLOW_PID=$!

# Wait until Langflow is reachable before starting nginx
python3 - <<PY
import socket, time, sys
host="127.0.0.1"
port=int("${LANGFLOW_PORT}")
deadline=time.time()+170  # keep < your 180s ECS grace period
while time.time()<deadline:
    try:
        s=socket.create_connection((host,port),timeout=1)
        s.close()
        sys.exit(0)
    except OSError:
        time.sleep(0.5)
print(f"Langflow not listening on {host}:{port} after 170s", file=sys.stderr)
sys.exit(1)
PY

# If Langflow exits, bring container down (ECS will restart it)
( wait "$LANGFLOW_PID"; exit 1 ) &

exec nginx -g 'daemon off;'
