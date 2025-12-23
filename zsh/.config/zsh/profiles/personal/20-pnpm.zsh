[[ -o interactive ]] || return

# Alias only if pnpm exists
if command -v pnpm >/dev/null 2>&1; then
  alias pn=pnpm
fi

# PNPM_HOME: only add if the directory exists
PNPM_HOME="$HOME/Library/pnpm"
if [[ -d "$PNPM_HOME" ]]; then
  export PNPM_HOME
  path_add "$PNPM_HOME"
fi
