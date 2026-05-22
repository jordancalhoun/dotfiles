# Load the profile settings, as well as any local settings if any
# 90-profiles.zsh
[[ -o interactive ]] || return

# Default profile if none is set
: "${ZSH_PROFILE:=personal}"

PROFILE_DIR="$HOME/.config/zsh/profiles/$ZSH_PROFILE"
if [[ -d "$PROFILE_DIR" ]]; then
  for f in "$PROFILE_DIR"/*.zsh(N); do
    source "$f"
  done
fi

# Local overrides (gitignored), optional
LOCAL_PROFILE="$HOME/.config/zsh/local/profile.zsh"
[[ -f "$LOCAL_PROFILE" ]] && source "$LOCAL_PROFILE"

LOCAL_SECRETS="$HOME/.config/zsh/local/secrets.zsh"
[[ -f "$LOCAL_SECRETS" ]] && source "$LOCAL_SECRETS"
