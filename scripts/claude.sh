#!/usr/bin/env bash

CLAUDE_SETTINGS="$HOME/.claude/settings.json"

# Claude Code rewrites settings.json itself, so it isn't stowed. Merge the
# statusLine entry into it instead, keeping every other setting.
configure_claude_statusline() {
  local tmp=""

  if ! command -v jq >/dev/null 2>&1; then
    warn "Skipping Claude status line setting (jq not found)"
    return 0
  fi

  mkdir -p -- "$(dirname -- "$CLAUDE_SETTINGS")"
  [[ -f "$CLAUDE_SETTINGS" ]] || printf '{}\n' >"$CLAUDE_SETTINGS"

  tmp="$(mktemp)"
  if ! jq '.statusLine = {type: "command", command: "~/.claude/statusline.sh", padding: 0}' \
    "$CLAUDE_SETTINGS" >"$tmp"; then
    rm -f -- "$tmp"
    err "Could not update $CLAUDE_SETTINGS (invalid JSON?)"
    return 1
  fi
  mv -- "$tmp" "$CLAUDE_SETTINGS"
  log "Configured Claude status line in $CLAUDE_SETTINGS"
}
