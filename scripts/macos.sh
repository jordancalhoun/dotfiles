#!/usr/bin/env bash

install_herdr_spreader() {
  local legacy_config="$HOME/.config/herdr/plugins/config/herdr-plugin-workspace-manager/config.yml"

  if ! command -v herdr >/dev/null 2>&1; then
    err "herdr is unavailable after brew bundle; cannot install Spreader."
    return 1
  fi
  log "Installing/updating Herdr Spreader plugin"
  herdr plugin install yuk1ty/herdr-spreader --yes

  if herdr plugin list --plugin herdr-plugin-workspace-manager --json >/dev/null 2>&1; then
    log "Removing replaced Herdr workspace manager plugin"
    herdr plugin uninstall herdr-plugin-workspace-manager
  fi
  if [[ -L "$legacy_config" ]] && [[ "$(readlink "$legacy_config")" == *herdr-workspace-manager/* ]]; then
    unlink "$legacy_config"
    log "Removed obsolete workspace manager config link"
  fi
}

configure_1password_ssh() {
  local agent_socket="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
  local fish_local_dir="$HOME/.config/fish/local"
  local fish_agent_file="$fish_local_dir/10-1password-ssh-agent.fish"

  if [[ "$GH_AUTH_METHOD" == "token" ]]; then
    log "Skipping 1Password SSH setup on this token-authenticated machine"
    return 0
  fi
  if ! ask_yes_no "Configure the 1Password SSH agent?"; then
    log "Skipping 1Password SSH setup"
    return 0
  fi
  if [[ ! -d /Applications/1Password.app ]]; then
    err "1Password.app is unavailable after brew bundle."
    return 1
  fi

  log "Opening 1Password"
  open -a 1Password
  printf '%s\n' \
    "Complete these steps in 1Password:" \
    "  1) Sign in and unlock the 1Password app." \
    "  2) Open 1Password > Settings > Developer." \
    "  3) Turn on 'Use the SSH Agent'." \
    "  4) Ensure the vault containing your SSH keys is unlocked."
  if ! ask_yes_no "Have you enabled the 1Password SSH agent?"; then
    warn "Skipping SSH agent configuration; rerun setup when 1Password is ready."
    return 0
  fi

  ensure_dir "$fish_local_dir"
  if [[ -e "$fish_agent_file" ]] && ! grep -qxF \
    "set -gx SSH_AUTH_SOCK \"\$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"" \
    "$fish_agent_file"; then
    warn "Not overwriting existing file: $fish_agent_file"
    warn "Set SSH_AUTH_SOCK to: $agent_socket"
    return 0
  fi

  printf '%s\n' \
    '# Use SSH keys provided by the 1Password desktop app.' \
    'set -gx SSH_AUTH_SOCK "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"' \
    >"$fish_agent_file"
  log "Configured Fish to use the 1Password SSH agent"

  export SSH_AUTH_SOCK="$agent_socket"
  if ssh-add -l >/dev/null 2>&1; then
    log "Verified the 1Password SSH agent"
  else
    warn "The 1Password SSH agent is configured but did not report any keys."
    warn "Unlock the key vault, then verify with: ssh-add -l"
  fi
}

set_default_shell_fish() {
  local fish_bin="/opt/homebrew/bin/fish"

  if ! [[ -x "$fish_bin" ]]; then
    warn "fish not found at $fish_bin; skipping default-shell setup."
    warn "Run 'brew install fish' or adjust \$fish_bin and rerun."
    return 0
  fi
  if ! grep -qxF "$fish_bin" /etc/shells; then
    log "Adding $fish_bin to /etc/shells (requires sudo)"
    printf '%s\n' "$fish_bin" | sudo tee -a /etc/shells >/dev/null
  fi
  if [[ "$SHELL" != "$fish_bin" ]]; then
    log "Setting login shell to fish (may prompt for password)"
    chsh -s "$fish_bin"
  else
    log "Login shell is already fish"
  fi
}
