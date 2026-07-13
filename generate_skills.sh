#!/usr/bin/env bash
set -euo pipefail

# --------- helpers ---------
log() { printf "\033[1;32m%s\033[0m\n" "$*"; }
warn() { printf "\033[1;33m%s\033[0m\n" "$*"; }
err() { printf "\033[1;31m%s\033[0m\n" "$*"; }

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$REPO_DIR/skills/xcode-skills"

# --------- main ---------
if ! command -v xcrun >/dev/null 2>&1; then
  err "xcrun not found. Ensure Xcode Command Line Tools are installed."
  exit 1
fi

log "Cleaning: $OUTPUT_DIR"
if [[ -d "$OUTPUT_DIR" ]]; then
  find "$OUTPUT_DIR" -mindepth 1 -delete
else
  mkdir -p "$OUTPUT_DIR"
  log "Created: $OUTPUT_DIR"
fi

log "Exporting skills to: $OUTPUT_DIR"
xcrun agent skills export --output-dir "$OUTPUT_DIR"

log "Done ✅"