function stampeed --description 'Start a Herdr session with all configured workspaces'
    set -l session_name (__herdr_default_session)
    set -l session_name_set false
    set -l force false
    set -l prepare_only false

    for arg in $argv
        switch "$arg"
            case --force
                if test "$force" = true
                    echo "usage: stampeed [session-name] [--force] [--prepare-only]" >&2
                    return 2
                end
                set force true
            case --prepare-only
                if test "$prepare_only" = true
                    echo "usage: stampeed [session-name] [--force] [--prepare-only]" >&2
                    return 2
                end
                set prepare_only true
            case '-*'
                echo "stampeed: unknown option '$arg'" >&2
                echo "usage: stampeed [session-name] [--force] [--prepare-only]" >&2
                return 2
            case '*'
                if test "$session_name_set" = true
                    echo "usage: stampeed [session-name] [--force] [--prepare-only]" >&2
                    return 2
                end
                set session_name "$arg"
                set session_name_set true
        end
    end

    if test "$force" = true
        if set -q HERDR_ENV HERDR_SESSION; and test "$HERDR_ENV" = 1 -a "$HERDR_SESSION" = "$session_name"
            echo "herdr: detach from session '$session_name' before rebuilding it" >&2
            return 1
        end

        set -l sessions_json (command herdr session list --json); or return
        set -l session_running (string join \n -- $sessions_json | jq -r \
            --arg name "$session_name" \
            '.sessions[] | select(.name == $name) | .running')

        if test "$session_running" = true
            command herdr session stop "$session_name"; or return
        end
        if test -n "$session_running"
            if test "$session_name" = default
                # Herdr does not support deleting its implicit default session.
                # Once stopped, removing only its saved topology gives the next
                # server start the same clean state as deleting a named session.
                set -l default_session_state "$HOME/.config/herdr/session.json"
                if test -e "$default_session_state"
                    command unlink "$default_session_state"; or return
                end
            else
                command herdr session delete "$session_name"; or return
            end
        end
    end

    __herdr_ensure_session "$session_name"; or return

    __herdr_apply_spreader "$session_name"; or return

    __herdr_focus_agent "$session_name" codecarton.com-v2; or return
    if test "$prepare_only" = true
        return 0
    end
    command herdr session attach "$session_name"
end
