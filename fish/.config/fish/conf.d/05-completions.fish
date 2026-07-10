status is-interactive; or return

# Fish owns completion loading. Use fzf's fish integration when available.
if command -q fzf
    fzf --fish 2>/dev/null | source
end
