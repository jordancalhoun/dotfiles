#!/usr/bin/env bash
set -euo pipefail

# --------- config ---------
BASE_PACKAGES=(
  aerospace
  ghostty
  nvim
  starship
  tmux
  zsh
)

OPTIONAL_PACKAGES=(
  nvim12
)

DIRECTORIES=(
  # "$HOME/.config/tmux/local"
  # "$HOME/.config/zsh-local/post"
)

# Zsh loader block appended to ~/.zshrc (only once)
ZSHRC_LOADER_START="# >>> zsh config managed by stow >>>"
ZSHRC_LOADER_END="# <<< zsh config managed by stow <<<"
ZSHRC_LOADER_BLOCK=$(
  cat <<'EOF'
# >>> zsh config managed by stow >>>
source "$HOME/.config/zsh/zshrc"
# <<< zsh config managed by stow <<<
EOF
)

# --------- helpers ---------
log() { printf "\033[1;32m%s\033[0m\n" "$*"; }
warn() { printf "\033[1;33m%s\033[0m\n" "$*"; }
err() { printf "\033[1;31m%s\033[0m\n" "$*"; }

usage() {
  cat <<EOF
Usage: $(basename "$0") [options] [BREWFILE]

Options:
      --install-optional    Automatically answer "yes" to all prompts
      --skip-optional       Skip all OPTIONAL_PACKAGES without prompting
  -h, --help                Show this help message and exit

Arguments:
  BREWFILE               Optional path to Brewfile (absolute or relative).
                         Defaults to: $REPO_DIR/Brewfile

Examples:
  $(basename "$0")
  $(basename "$0") --yes
  $(basename "$0") --skip-optional
  $(basename "$0") -y --skip-optional
  $(basename "$0") ~/Brewfiles/work.Brewfile
  $(basename "$0") -y ~/Brewfiles/work.Brewfile
EOF
}

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

DEFAULT_BREWFILE="$REPO_DIR/Brewfile"
BREWFILE="$DEFAULT_BREWFILE"

AUTO_YES=0
SKIP_OPTIONAL=0
BREWFILE_ARG=""

for arg in "$@"; do
  case "$arg" in
  --install-optional)
    AUTO_YES=1
    ;;
  --skip-optional)
    SKIP_OPTIONAL=1
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    if [[ -z "$BREWFILE_ARG" ]]; then
      BREWFILE_ARG="$arg"
    else
      err "Unexpected argument: $arg"
      usage
      exit 1
    fi
    ;;
  esac
done

if [[ -n "$BREWFILE_ARG" ]]; then
  if [[ -f "$BREWFILE_ARG" ]]; then
    BREWFILE="$(cd "$(dirname "$BREWFILE_ARG")" && pwd)/$(basename "$BREWFILE_ARG")"
  else
    err "Provided Brewfile path does not exist: $BREWFILE_ARG"
    exit 1
  fi
fi

if [[ -n "$BREWFILE_ARG" ]]; then
  if [[ -f "$BREWFILE_ARG" ]]; then
    BREWFILE="$(cd "$(dirname "$BREWFILE_ARG")" && pwd)/$(basename "$BREWFILE_ARG")"
  else
    err "Provided Brewfile path does not exist: $BREWFILE_ARG"
    exit 1
  fi
fi

TS="$(date +%Y%m%d-%H%M%S)"

ensure_brew_in_path() {
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

ask_yes_no() {
  local prompt="$1"
  local ans=""
  if [[ "$AUTO_YES" -eq 1 ]]; then
    return 0
  fi
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

append_zshrc_loader_once() {
  local zshrc="$HOME/.zshrc"

  # Refuse to edit a symlink (prevents writing into the repo if stow ever linked it)
  if [[ -L "$zshrc" ]]; then
    warn "~/.zshrc is a symlink. Refusing to modify it."
    warn "Remove it or restore a real file, then rerun setup."
    return 1
  fi

  # Create ~/.zshrc if missing (as a real file)
  [[ -e "$zshrc" ]] || : >"$zshrc"

  if grep -qF "$ZSHRC_LOADER_START" "$zshrc"; then
    log "Zsh loader already present in ~/.zshrc"
    return 0
  fi

  log "Appending zsh loader to ~/.zshrc"
  printf "\n%s\n" "$ZSHRC_LOADER_BLOCK" >>"$zshrc"
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

create_directories() {
  local dir

  for dir in "${DIRECTORIES[@]}"; do
    ensure_dir "$dir"
  done
}

# If target exists and isn't the correct stow symlink, rename it in place:
#   ~/.config/zsh  ->  ~/.config/zsh.stow-bak-YYYYMMDD-HHMMSS (or with -2, -3 if needed)
rename_conflict_in_place() {
  local target="$1"
  local bak="${target}.stow-bak-${TS}"
  local n=2

  # Find an unused backup name
  while [[ -e "$bak" || -L "$bak" ]]; do
    bak="${target}.stow-bak-${TS}-${n}"
    n=$((n + 1))
  done

  log "Renaming conflict:"
  log "  $target"
  log "  -> $bak"
  mv -- "$target" "$bak"
}

# Extract conflicting target paths from stow dry-run output.
# Returns newline-separated relative paths (relative to $HOME).
stow_conflict_paths_from_output() {
  # Stow typically prints lines like:
  #   * existing target is neither a link nor a directory: .config/nvim
  #   * existing target is a directory: .zshrc
  #
  # We grab whatever comes after the final ": " on those bullet lines.
  grep -E '^\s*\*\s+existing target .*: ' |
    sed -E 's/^.*: //'
}

stow_restow_with_backups_on_conflict() {
  local pkg="$1"

  # Dry run first so Stow decides what’s a conflict
  local out=""
  local conflicts=""
  if ! out="$(stow -n -R -v -d "$REPO_DIR" -t "$HOME" "$pkg" 2>&1)"; then
    # If it failed due to conflicts, parse them; otherwise fail hard with output
    if grep -q "would cause conflicts" <<<"$out"; then
      conflicts="$(stow_conflict_paths_from_output <<<"$out" | sed '/^$/d' || true)"
      if [[ -z "$conflicts" ]]; then
        err "Stow reported conflicts but I couldn't parse them. Output:"
        echo "$out"
        return 1
      fi

      warn "Conflicts detected by stow for '$pkg' — backing up only those paths:"
      while IFS= read -r rel; do
        [[ -n "$rel" ]] || continue
        rename_conflict_in_place "$HOME/$rel"
      done <<<"$conflicts"

      # Re-run dry run; if still conflicts, abort and show output
      if ! out="$(stow -n -R -v -d "$REPO_DIR" -t "$HOME" "$pkg" 2>&1)"; then
        err "Still conflicts after backups for '$pkg'. Stow output:"
        echo "$out"
        return 1
      fi
    else
      err "Stow dry-run failed for '$pkg' (not a conflict error). Output:"
      echo "$out"
      return 1
    fi
  fi

  # Now do the real stow
  stow -R -v -d "$REPO_DIR" -t "$HOME" "$pkg"
}

# --------- main ---------
log "Repo: $REPO_DIR"

# 1) Homebrew
if ! command -v brew >/dev/null 2>&1; then
  log "Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ensure_brew_in_path
else
  ensure_brew_in_path
  log "Homebrew found: $(command -v brew)"
fi

# 2) Brewfile packages
if [[ -f "$BREWFILE" ]]; then
  log "Running brew bundle (no-upgrade) from: $BREWFILE"
  brew bundle --file "$BREWFILE" --no-upgrade
else
  warn "No Brewfile at $BREWFILE (skipping brew bundle)"
fi

# 3) Ensure stow
if ! command -v stow >/dev/null 2>&1; then
  log "Installing stow..."
  brew install stow
fi

# 4) Ensure ~/.config exists (many packages target it)
mkdir -p "$HOME/.config"

# Create the local direcotires if they don't exist
create_directories

# 5) Append zsh loader once (so ~/.zshrc loads ~/.config/zsh/zshrc)
append_zshrc_loader_once

# 6) Build package list (optionally include OPTIONAL_PACKAGES)
STOW_PACKAGES=("${BASE_PACKAGES[@]}")

if [[ "$SKIP_OPTIONAL" -eq 1 ]]; then
  log "Skipping all optional packages (--skip-optional)."
else
  for opt in "${OPTIONAL_PACKAGES[@]}"; do
    # Only prompt/include optionals that actually exist in the repo
    if [[ ! -d "$REPO_DIR/$opt" ]]; then
      warn "Optional package '$opt' not found in repo (skipping)"
      continue
    fi

    if ask_yes_no "Stow optional package '$opt'?"; then
      STOW_PACKAGES+=("$opt")
    else
      log "Skipping optional package: $opt"
    fi
  done
fi

# 7) Preflight: rename conflicts, then stow
cd "$REPO_DIR"

for pkg in "${STOW_PACKAGES[@]}"; do
  if [[ ! -d "$REPO_DIR/$pkg" ]]; then
    warn "Skipping '$pkg' (directory not found)"
    continue
  fi

  log "Stowing (stow-driven conflict backups): $pkg"
  stow_restow_with_backups_on_conflict "$pkg"
done

log "Done ✅"
log "Any conflicts were renamed with suffix: .stow-bak-${TS}"
