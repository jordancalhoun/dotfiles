#!/usr/bin/env bash

GH_AUTH_METHOD=""

configure_gh_auth() {
  local user_type="$1"
  local auth_method=""
  local token=""

  if ! command -v gh >/dev/null 2>&1; then
    err "gh is unavailable after brew bundle; cannot configure GitHub authentication."
    return 1
  fi

  if gh auth status --hostname github.com >/dev/null 2>&1; then
    GH_AUTH_METHOD="existing"
    log "GitHub CLI is already authenticated"
    return 0
  fi

  printf '%s\n' \
    "Choose a GitHub CLI authentication method:" \
    "  1) Browser/device login (recommended for user machines)" \
    "  2) Fine-grained personal access token (recommended for agent machines)" \
    "Machine user type: $user_type"

  while true; do
    printf "Selection [1/2]: "
    IFS= read -r auth_method
    case "$auth_method" in
    1)
      gh auth login --hostname github.com --git-protocol ssh --skip-ssh-key --web || {
        err "GitHub CLI browser/device authentication failed."
        return 1
      }
      GH_AUTH_METHOD="browser"
      break
      ;;
    2)
      printf "Enter a fine-grained GitHub personal access token: "
      IFS= read -r -s token
      printf "\n"
      if [[ -z "$token" ]]; then
        err "A token is required to authenticate GitHub CLI."
        return 1
      fi
      if ! printf '%s\n' "$token" | gh auth login \
        --hostname github.com --git-protocol ssh --skip-ssh-key --with-token; then
        token=""
        err "GitHub CLI token authentication failed."
        return 1
      fi
      token=""
      GH_AUTH_METHOD="token"
      break
      ;;
    *) warn "Please enter 1 or 2." ;;
    esac
  done

  log "GitHub CLI authenticated"
}
