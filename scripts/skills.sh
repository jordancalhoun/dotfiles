#!/usr/bin/env bash

link_skills_to_tool() {
  local dest_root="$1"
  local src="" name="" dest=""

  mkdir -p -- "$dest_root"
  while IFS= read -r -d '' skill_md; do
    src="$(dirname -- "$skill_md")"
    name="$(basename -- "$src")"
    dest="$dest_root/$name"
    if [[ -L "$dest" ]]; then
      log "Skill link exists: $dest"
    elif [[ -e "$dest" ]]; then
      warn "Skipping '$name': non-symlink already present at $dest"
    else
      ln -s -- "$src" "$dest"
      log "Linked skill: $dest -> $src"
    fi
  done < <(find -- "$REPO_DIR/skills" -type f -name SKILL.md -print0)
}

link_skills_to_tools() {
  local tools=(
    $'claude\t'"$HOME/.claude/skills"
    $'codex\t'"$HOME/.codex/skills"
    $'opencode\t'"$HOME/.config/opencode/skills"
  )
  local entry name dest conf_home

  for entry in "${tools[@]}"; do
    name="${entry%%$'\t'*}"
    dest="${entry#*$'\t'}"
    conf_home="$(dirname -- "$dest")"
    if ! command -v "$name" >/dev/null 2>&1 && [[ ! -d "$conf_home" ]]; then
      log "Skipping skill links for '$name' (not found)"
      continue
    fi
    log "Linking skills for '$name' -> $dest"
    link_skills_to_tool "$dest"
  done
}
