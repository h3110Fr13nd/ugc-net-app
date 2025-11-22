#!/usr/bin/env bash
set -euo pipefail

# Run the Flutter app with API_BASE_URL read from the repo .env file.
# Usage: ./scripts/run_flutter_with_env.sh [device-id]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="$REPO_ROOT/.env"

if [ -f "$ENV_FILE" ]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
fi

if [ -z "${API_BASE_URL:-}" ]; then
  echo "API_BASE_URL is not set in $ENV_FILE"
  echo "Please edit $ENV_FILE or pass --dart-define manually."
  exit 1
fi

DEVICE_ARG=""
if [ -n "${1:-}" ]; then
  DEVICE_ARG="-d $1"
fi

echo "Running flutter with API_BASE_URL=$API_BASE_URL"
flutter run $DEVICE_ARG --dart-define="API_BASE_URL=$API_BASE_URL"
