#!/usr/bin/env sh
set -eu

: "${APP_PASSWORD:?Set APP_PASSWORD in Flightcontrol env vars}"

# Start Langflow on internal port (nginx will listen on 7860)
LANGFLOW_PORT="${LANGFLOW_PORT:-7861}"
langflow run --host 0.0.0.0 --port "$LANGFLOW_PORT" &
LANGFLOW_PID=$!

# Wait until Langflow is reachable before starting nginx
python3 - <<PY
import socket, time, sys
host="127.0.0.1"
port=int("${LANGFLOW_PORT}")
deadline=time.time()+170  # < your 180s grace period
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

# If langflow exits, bring the container down (ECS will restart)
( wait "$LANGFLOW_PID"; exit 1 ) &

exec nginx -g 'daemon off;'
