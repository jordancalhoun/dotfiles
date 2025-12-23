# 50-completion.zsh
[[ -o interactive ]] || return

autoload -Uz compinit
# Use a cache dir if available; falls back safely
_compdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
mkdir -p -- "${_compdump:h}" 2>/dev/null
compinit -d "$_compdump"

# Styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
[[ -n "$LS_COLORS" ]] && zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no

# Only set GNU `ls --color` previews if it exists
if command -v ls >/dev/null 2>&1; then
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath 2>/dev/null || ls $realpath'
  zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath 2>/dev/null || ls $realpath'
fi
