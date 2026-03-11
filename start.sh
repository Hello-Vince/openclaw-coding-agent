#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "Starting OpenClaw..."
docker compose up -d --build

echo "Waiting for gateway to be ready..."
for i in $(seq 1 30); do
  if docker exec openclaw-agent openclaw health &>/dev/null; then
    break
  fi
  sleep 1
done

URL=$(docker exec openclaw-agent openclaw dashboard --no-open 2>&1 | grep -oE 'http://[^ ]+')

if [ -z "$URL" ]; then
  echo "Error: could not retrieve dashboard URL."
  exit 1
fi

echo ""
echo "============================================="
echo "  Open this URL in your browser:"
echo ""
echo "  $URL"
echo ""
echo "  (token is embedded -- no manual paste needed)"
echo "============================================="
echo ""

# Auto-approve device pairing requests for 90 seconds in the background.
(
  end=$((SECONDS + 90))
  while [ $SECONDS -lt $end ]; do
    json=$(docker exec openclaw-agent openclaw devices list --json 2>/dev/null || true)
    if [ -n "$json" ]; then
      # Extract requestId values from the pending array using grep/sed (no python needed)
      request_ids=$(echo "$json" | grep -o '"requestId"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"requestId"[[:space:]]*:[[:space:]]*"//;s/"//' || true)
      for rid in $request_ids; do
        [ -z "$rid" ] && continue
        echo "[auto-approve] approving request $rid"
        docker exec openclaw-agent openclaw devices approve "$rid" 2>/dev/null || true
      done
    fi
    sleep 3
  done
  echo "[auto-approve] watcher finished (90s elapsed)"
) &
APPROVER_PID=$!

echo "Device auto-approver running in background (PID $APPROVER_PID, 90s)."
echo "Press Ctrl+C to stop, or it will stop on its own."
echo ""

# If the user Ctrl+C's, kill the background approver.
trap "kill $APPROVER_PID 2>/dev/null; echo 'Stopped.'; exit 0" INT TERM

if command -v open &>/dev/null; then
  open "$URL"
elif command -v xdg-open &>/dev/null; then
  xdg-open "$URL"
fi

wait $APPROVER_PID 2>/dev/null || true
echo "Done. Container is running. Use 'docker compose down' to stop."
