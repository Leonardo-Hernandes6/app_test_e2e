#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PORT=8080
SLOW_MO_MS="${E2E_SLOW_MO_MS:-0}"
SERVER_LOG="$(mktemp -t demo_api)"

cleanup() {
  if [[ -n "${SERVER_PID:-}" ]]; then
    kill "$SERVER_PID" 2>/dev/null || true
    wait "$SERVER_PID" 2>/dev/null || true
  fi
  rm -f "$SERVER_LOG"
}
trap cleanup EXIT

if curl -fsS "http://localhost:$PORT/health" >/dev/null 2>&1; then
  echo "Port $PORT is already in use. Stop the process using it and try again." >&2
  exit 1
fi

echo "▶ Starting demo API on :$PORT"
(cd "$ROOT/server" && dart pub get >/dev/null)
(cd "$ROOT/server" && PORT="$PORT" exec dart bin/server.dart) >"$SERVER_LOG" 2>&1 &
SERVER_PID=$!

for _ in $(seq 1 60); do
  curl -fsS "http://localhost:$PORT/health" >/dev/null 2>&1 && break
  if ! kill -0 "$SERVER_PID" 2>/dev/null; then cat "$SERVER_LOG" >&2; exit 1; fi
  sleep 0.5
done
curl -fsS "http://localhost:$PORT/health" >/dev/null || {
  echo "Demo API did not start:" >&2; cat "$SERVER_LOG" >&2; exit 1;
}

echo "▶ Running E2E suite"
cd "$ROOT"
flutter test integration_test \
  --dart-define=E2E_SLOW_MO_MS="$SLOW_MO_MS" \
  "$@"
