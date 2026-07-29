# Helper: add existing directories to PATH without duplicates.
set --global fish_greeting

function path_add
    for dir in $argv
        test -d "$dir"; or continue
        fish_add_path --global --append --move "$dir"
    end
end

status is-interactive; or return

# User-installed command-line tools.
path_add "$HOME/.opencode/bin"
path_add "$HOME/.local/bin"
path_add "$HOME/.local/share/bob/nvim-bin"

if command -q opencode
    alias code=opencode
end

# Start a remote Herdr session on Mac mini.
function herdr-mini
    herdr --remote ssh://mini
end
