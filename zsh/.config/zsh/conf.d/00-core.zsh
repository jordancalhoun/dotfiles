# 00-core.zsh

# Only run in zsh
[[ -n "$ZSH_VERSION" ]] || return

# Make $path unique to avoid duplicates when re-sourcing
typeset -U path PATH

# Helper: add to PATH only if directory exists and isn’t already present
path_add() {
  local dir="$1"
  [[ -d "$dir" ]] || return 0
  path+=("$dir")
}
