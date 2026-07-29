#!/usr/bin/env bash

ensure_brew_in_path() {
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

install_homebrew_bundle() {
  local brewfile="$1"

  if ! command -v brew >/dev/null 2>&1; then
    log "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  ensure_brew_in_path
  log "Homebrew found: $(command -v brew)"

  if [[ ! -f "$brewfile" ]]; then
    err "Required Brewfile not found: $brewfile"
    return 1
  fi

  log "Running brew bundle (no-upgrade) from: $brewfile"
  brew bundle --file "$brewfile" --no-upgrade
}

ensure_stow() {
  if ! command -v stow >/dev/null 2>&1; then
    log "Installing stow..."
    brew install stow
  fi
}
