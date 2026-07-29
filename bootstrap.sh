#!/usr/bin/env bash
set -euo pipefail

REPOSITORY_URL="https://github.com/jordancalhoun/dotfiles.git"
PROJECTS_DIR="$HOME/Projects"
DOTFILES_DIR="$PROJECTS_DIR/dotfiles"

if ! command -v git >/dev/null 2>&1; then
  printf '%s\n' "Error: git is required to clone the dotfiles repository." >&2
  exit 1
fi

if [[ -e "$DOTFILES_DIR" || -L "$DOTFILES_DIR" ]]; then
  printf '%s\n' "Error: clone destination already exists: $DOTFILES_DIR" >&2
  exit 1
fi

mkdir -p -- "$PROJECTS_DIR"
printf '%s\n' "Cloning dotfiles into: $DOTFILES_DIR"
git clone "$REPOSITORY_URL" "$DOTFILES_DIR"

if [[ ! -r /dev/tty ]]; then
  printf '%s\n' "Error: setup requires an interactive terminal." >&2
  exit 1
fi

printf '%s\n' "Starting dotfiles setup..."
exec /bin/bash "$DOTFILES_DIR/setup.sh" </dev/tty
