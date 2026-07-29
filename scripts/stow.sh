#!/usr/bin/env bash

BASE_PACKAGES=(aerospace fish ghostty herdr herdr-spreader lazygit nvim starship tmux xcode)

rename_conflict_in_place() {
  local target="$1"
  local timestamp="$2"
  local bak="${target}.stow-bak-${timestamp}"
  local n=2
  while [[ -e "$bak" || -L "$bak" ]]; do
    bak="${target}.stow-bak-${timestamp}-${n}"
    n=$((n + 1))
  done
  log "Renaming conflict:"
  log "  $target"
  log "  -> $bak"
  mv -- "$target" "$bak"
}

stow_conflict_paths_from_output() {
  sed -nE \
    -e 's/^[[:space:]]*\*[[:space:]]+existing target .*: (.*)$/\1/p' \
    -e 's/^[[:space:]]*\*[[:space:]]+cannot stow .* over existing target (.*) since .*$/\1/p'
}

stow_restow_with_backups_on_conflict() {
  local pkg="$1"
  local timestamp="$2"
  local out=""
  local conflicts=""

  if ! out="$(stow -n -R -v -d "$REPO_DIR" -t "$HOME" "$pkg" 2>&1)"; then
    if grep -q "would cause conflicts" <<<"$out"; then
      conflicts="$(stow_conflict_paths_from_output <<<"$out" | sed '/^$/d' || true)"
      if [[ -z "$conflicts" ]]; then
        err "Stow reported conflicts but they could not be parsed. Output:"
        echo "$out"
        return 1
      fi
      warn "Conflicts detected by stow for '$pkg' — backing up only those paths:"
      while IFS= read -r rel; do
        [[ -n "$rel" ]] || continue
        rename_conflict_in_place "$HOME/$rel" "$timestamp"
      done <<<"$conflicts"
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
  stow -R -v -d "$REPO_DIR" -t "$HOME" "$pkg"
}

stow_dotfiles() {
  local timestamp="$1"
  local pkg

  cd "$REPO_DIR"
  for pkg in "${BASE_PACKAGES[@]}"; do
    if [[ ! -d "$REPO_DIR/$pkg" ]]; then
      warn "Skipping '$pkg' (directory not found)"
      continue
    fi
    log "Stowing (stow-driven conflict backups): $pkg"
    stow_restow_with_backups_on_conflict "$pkg" "$timestamp"
  done
}
