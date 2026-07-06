#!/usr/bin/env bash
# Run Patrol integration tests for Sello (Android, iOS, or web).
#
# Examples:
#   ./scripts/run_patrol_tests.sh
#   PLATFORM=web ./scripts/run_patrol_tests.sh
#   PLATFORM=ios TARGET=patrol_test/guest_home_smoke_test.dart ./scripts/run_patrol_tests.sh
#   DEVICE=chrome ./scripts/run_patrol_tests.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

ENV_FILE="${ENV_FILE:-env.json}"
PLATFORM="${PLATFORM:-ios}"
TARGET="${TARGET:-patrol_test/guest_search_empty_state_test.dart}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing $ENV_FILE — copy env.json.example and fill Supabase keys." >&2
  exit 1
fi

export PATH="${PATH:+$PATH:}$HOME/.pub-cache/bin"

if ! command -v patrol >/dev/null 2>&1; then
  echo "Installing patrol_cli …" >&2
  flutter pub global activate patrol_cli
fi

resolve_device() {
  if [[ -n "${DEVICE:-}" ]]; then
    echo "$DEVICE"
    return
  fi

  case "$PLATFORM" in
    android)
      if ! command -v adb >/dev/null 2>&1; then
        echo "Android SDK is not configured (adb missing / ANDROID_HOME unset)." >&2
        echo "Install Android Studio, set ANDROID_HOME, and start an emulator — or use:" >&2
        echo "  PLATFORM=ios ./scripts/run_patrol_tests.sh" >&2
        echo "  PLATFORM=web ./scripts/run_patrol_tests.sh" >&2
        exit 1
      fi
      echo ""
      ;;
    ios)
      echo "502836F8-946D-4D08-96B4-77856DA0C410"
      ;;
    web | chrome)
      echo "chrome"
      ;;
    macos)
      echo "macos"
      ;;
    *)
      echo "Unknown PLATFORM=$PLATFORM (use android, ios, web, or macos)." >&2
      exit 1
      ;;
  esac
}

DEVICE_ID="$(resolve_device)"

echo "→ Patrol ($PLATFORM): $TARGET with $ENV_FILE"
args=(
  test
  --target "$TARGET"
  --dart-define-from-file="$ENV_FILE"
)

if [[ -n "$DEVICE_ID" ]]; then
  args+=(--device "$DEVICE_ID")
fi

if [[ "$PLATFORM" == "web" || "$PLATFORM" == "chrome" ]]; then
  args+=(--web-headless=false)
fi

patrol "${args[@]}"
