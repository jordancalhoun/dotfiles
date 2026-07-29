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
    set -l session_name default
    set -l session_name_set false
    set -l force false

    for arg in $argv
        switch "$arg"
            case --force
                if test "$force" = true
                    echo "usage: herdr-mini [session-name] [--force]" >&2
                    return 2
                end
                set force true
            case '-*'
                echo "herdr-mini: unknown option '$arg'" >&2
                echo "usage: herdr-mini [session-name] [--force]" >&2
                return 2
            case '*'
                if test "$session_name_set" = true
                    echo "usage: herdr-mini [session-name] [--force]" >&2
                    return 2
                end
                set session_name "$arg"
                set session_name_set true
        end
    end

    if not string match -rq '^[A-Za-z0-9][A-Za-z0-9._-]*$' -- "$session_name"
        echo "herdr-mini: invalid session name '$session_name'" >&2
        return 2
    end

    if test "$force" = true
        set -l stampeed_command "stampeed $session_name --force --prepare-only"
        set -l remote_command "fish -lc "(string escape -- "$stampeed_command")
        command ssh mini "$remote_command"; or return
    end

    command herdr --remote ssh://mini --session "$session_name"
end
