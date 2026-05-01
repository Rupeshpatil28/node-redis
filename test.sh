#!/usr/bin/env bash
set -euo pipefail

output_path=""
mode=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output_path)
      output_path="$2"
      shift 2
      ;;
    base|new)
      mode="$1"
      shift
      ;;
    *)
      shift
      ;;
  esac
done

if [[ -z "$output_path" || -z "$mode" ]]; then
  echo "Usage: ./test.sh --output_path <path> base|new" >&2
  exit 1
fi

mkdir -p "$(dirname "$output_path")"

cd "$(dirname "$0")/packages/client"

export MOCHA_FILE="$output_path"

MOCHA_ARGS=(-r tsx --reporter mocha-multi-reporters --reporter-options configFile=mocha-multi-reporter-config.json --exit './lib/**/*.spec.ts')

if [[ "$mode" == "base" ]]; then
  ./node_modules/.bin/mocha "${MOCHA_ARGS[@]}" --grep "offlineQueueRejectionHook" --invert
elif [[ "$mode" == "new" ]]; then
  ./node_modules/.bin/mocha "${MOCHA_ARGS[@]}" --grep "offlineQueueRejectionHook"
else
  echo "Unknown mode: $mode" >&2
  exit 1
fi
