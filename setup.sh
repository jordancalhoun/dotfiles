#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/common.sh
source "$REPO_DIR/scripts/common.sh"
# shellcheck source=scripts/homebrew.sh
source "$REPO_DIR/scripts/homebrew.sh"
# shellcheck source=scripts/github.sh
source "$REPO_DIR/scripts/github.sh"
# shellcheck source=scripts/repositories.sh
source "$REPO_DIR/scripts/repositories.sh"
# shellcheck source=scripts/stow.sh
source "$REPO_DIR/scripts/stow.sh"
# shellcheck source=scripts/macos.sh
source "$REPO_DIR/scripts/macos.sh"
# shellcheck source=scripts/skills.sh
source "$REPO_DIR/scripts/skills.sh"

usage() {
  cat <<EOF
Usage: $(basename "$0")

Options:
  -h, --help    Show this help message and exit

The first prompt selects whether this is an agent or user machine.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  -h | --help)
    usage
    exit 0
    ;;
  *)
    err "Unexpected argument: $1"
    usage
    exit 1
    ;;
  esac
done

prompt_for_user_type() {
  local selection=""

  printf '%s\n' \
    "Choose the machine user type:" \
    "  1) User" \
    "  2) Agent"

  while true; do
    printf "Selection [1/2]: "
    IFS= read -r selection
    case "$selection" in
    1 | user)
      USER_TYPE="user"
      return 0
      ;;
    2 | agent)
      USER_TYPE="agent"
      return 0
      ;;
    *) warn "Please enter 1 or 2." ;;
    esac
  done
}

USER_TYPE=""
prompt_for_user_type

BREWFILE="$REPO_DIR/Brewfile.$USER_TYPE"
TS="$(date +%Y%m%d-%H%M%S)"

log "Repo: $REPO_DIR"
log "User type: $USER_TYPE"

install_homebrew_bundle "$BREWFILE"
configure_gh_auth "$USER_TYPE"
offer_to_clone_repositories "$USER_TYPE"
ensure_stow
mkdir -p "$HOME/.config"
install_herdr_workspace_manager
stow_dotfiles "$TS"

if [[ "$USER_TYPE" == "user" ]]; then
  configure_1password_ssh
fi

if ask_yes_no "Set fish as the default login shell?"; then
  set_default_shell_fish
fi

link_skills_to_tools

log "Done ✅"
log "Any conflicts were renamed with suffix: .stow-bak-${TS}"
