#!/usr/bin/env bash
# test.sh – test harness for the offlineQueueRejectionHook feature.
#
# Usage:
#   ./test.sh --mode base|new --output_path <path>
#
# --mode base  : run all existing tests, excluding the new offlineQueueRejectionHook tests
# --mode new   : run only the new offlineQueueRejectionHook tests
# --output_path: absolute or relative path where JUnit XML output is written

set -euo pipefail

MODE=""
OUTPUT_PATH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      MODE="$2"
      shift 2
      ;;
    --output_path)
      OUTPUT_PATH="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if [[ -z "$MODE" ]]; then
  echo "Error: --mode is required (base or new)" >&2
  exit 1
fi

if [[ -z "$OUTPUT_PATH" ]]; then
  echo "Error: --output_path is required" >&2
  exit 1
fi

# Resolve output path to an absolute path
OUTPUT_PATH="$(realpath -m "$OUTPUT_PATH")"

# Ensure output directory exists
mkdir -p "$(dirname "$OUTPUT_PATH")"

cd "$(dirname "$0")/packages/client"

# The MOCHA_FILE env var tells mocha-junit-reporter where to write the XML.
export MOCHA_FILE="$OUTPUT_PATH"

MOCHA_ARGS=(-r tsx --reporter mocha-multi-reporters --reporter-options configFile=mocha-multi-reporter-config.json --exit './lib/**/*.spec.ts')

case "$MODE" in
  new)
    # Run only the new offlineQueueRejectionHook tests
    npx mocha "${MOCHA_ARGS[@]}" --grep "offlineQueueRejectionHook"
    ;;
  base)
    # Run all existing tests, excluding the new offlineQueueRejectionHook tests
    npx mocha "${MOCHA_ARGS[@]}" --grep "offlineQueueRejectionHook" --invert
    ;;
  *)
    echo "Error: --mode must be 'base' or 'new'" >&2
    exit 1
    ;;
esac
