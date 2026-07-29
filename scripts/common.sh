#!/usr/bin/env bash

log() { printf "\033[1;32m%s\033[0m\n" "$*"; }
warn() { printf "\033[1;33m%s\033[0m\n" "$*"; }
err() { printf "\033[1;31m%s\033[0m\n" "$*"; }

ask_yes_no() {
  local prompt="$1"
  local ans=""

  while true; do
    read -r -p "$prompt [y/N]: " ans
    ans="$(printf "%s" "$ans" | tr '[:upper:]' '[:lower:]')"
    case "$ans" in
    y | yes) return 0 ;;
    n | no | "") return 1 ;;
    *) echo "Please answer y or n." ;;
    esac
  done
}

ensure_dir() {
  local dir

  if [[ $# -ne 1 || -z "$1" ]]; then
    warn "ensure_dir: invalid directory"
    return 2
  fi

  dir=$1
  if [[ -d "$dir" ]]; then
    log "Exists: $dir"
  else
    mkdir -p -- "$dir"
    log "Created: $dir"
  fi
}
