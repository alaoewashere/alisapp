#!/usr/bin/env bash
# Build and serve Sello Flutter web for TestSprite / headless browser testing.
# The `flutter run -d chrome` debug server often returns ERR_EMPTY_RESPONSE under
# TestSprite's parallel tunnel connections; a release build + static server is stable.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PORT="${PORT:-8080}"
HOST="${HOST:-127.0.0.1}"
ENV_FILE="${ENV_FILE:-env.json}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing $ENV_FILE — copy env.json.example and fill in Supabase keys." >&2
  exit 1
fi

if lsof -i ":${PORT}" -sTCP:LISTEN >/dev/null 2>&1; then
  echo "Port ${PORT} is already in use (TestSprite expects http://${HOST}:${PORT}). Stop it first:" >&2
  lsof -i ":${PORT}" -sTCP:LISTEN >&2 || true
  exit 1
fi

echo "→ Building Flutter web (release) with $ENV_FILE …"
flutter build web --release --dart-define-from-file="$ENV_FILE"

echo "→ Serving SPA at http://${HOST}:${PORT} (Ctrl+C to stop) …"
exec npx --yes serve -s build/web -l "tcp://${HOST}:${PORT}"
