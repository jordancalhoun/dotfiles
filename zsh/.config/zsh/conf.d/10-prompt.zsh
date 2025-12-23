# 10-prompt-starship.zsh

# Prompt only makes sense interactively
[[ -o interactive ]] || return

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
