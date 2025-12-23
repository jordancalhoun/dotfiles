[[ -o interactive ]] || return

# Rails editor
export EDITOR="nvim"

# rbenv only if installed
if command -v rbenv >/dev/null 2>&1; then
  eval "$(rbenv init - zsh)"
fi
