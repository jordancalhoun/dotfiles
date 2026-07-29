function __herdr_apply_spreader --argument-names session_name
    if test -z "$session_name"
        echo "__herdr_apply_spreader: a session name is required" >&2
        return 2
    end

    set -l workspace_json (command herdr --session "$session_name" workspace list); or return
    set -l workspace_count (string join \n -- $workspace_json | jq -r '.result.workspaces | length')

    # Spreader creates rather than reconciles workspaces, so only apply its
    # declarative layout to a truly empty session.
    if test "$workspace_count" -gt 0
        set -l workspace_labels (string join \n -- $workspace_json | jq -r '.result.workspaces[].label')
        set -l missing_workspaces
        for expected_workspace in codecarton.com-v2 Devote One16 Ditches dotfiles
            contains -- "$expected_workspace" $workspace_labels; or set --append missing_workspaces "$expected_workspace"
        end
        if test (count $missing_workspaces) -gt 0
            echo "herdr: session '$session_name' has a partial layout; missing: "(string join ', ' -- $missing_workspaces) >&2
            return 1
        end
        return 0
    end

    # Plugin actions require a workspace invocation context. Give Spreader a
    # temporary focused workspace, then remove it after the real layout exists.
    set -l bootstrap_json (command herdr --session "$session_name" workspace create \
        --cwd "$HOME/Projects/dotfiles" \
        --label __spreader_bootstrap \
        --focus); or return
    set -l bootstrap_id (string join \n -- $bootstrap_json | jq -r '.result.workspace.workspace_id // empty')
    if test -z "$bootstrap_id"
        echo "herdr: Spreader bootstrap workspace did not return an ID" >&2
        return 1
    end

    # Invoking an action only queues it; a zero exit status does not mean the
    # plugin command has finished. Wait for this invocation's log before using
    # or removing the workspace that supplied its invocation context.
    set -l apply_json (command herdr --session "$session_name" plugin action invoke herdr-spreader.apply)
    set -l apply_status $status
    set -l apply_log_id

    if test $apply_status -eq 0
        set apply_log_id (string join \n -- $apply_json | jq -r '.result.log.log_id // empty')
        if test -z "$apply_log_id"
            echo "herdr: Spreader invocation did not return a log ID" >&2
            set apply_status 1
        end
    end

    if test $apply_status -eq 0
        set -l apply_state running
        set -l apply_log

        for attempt in (seq 1 300)
            set -l logs_json (command herdr --session "$session_name" plugin log list \
                --plugin herdr-spreader \
                --limit 10)
            set -l logs_status $status
            if test $logs_status -ne 0
                set apply_status $logs_status
                break
            end

            set apply_log (string join \n -- $logs_json | jq -c \
                --arg log_id "$apply_log_id" \
                '.result.logs[] | select(.log_id == $log_id)' | head -n 1)
            if test -n "$apply_log"
                set apply_state (string join \n -- $apply_log | jq -r '.status')
                test "$apply_state" != running; and break
            end
            sleep 0.1
        end

        if test $apply_status -eq 0
            switch "$apply_state"
                case succeeded
                case running
                    echo "herdr: timed out waiting for Spreader" >&2
                    set apply_status 1
                case '*'
                    set -l apply_stderr (string join \n -- $apply_log | jq -r '.stderr // empty')
                    test -n "$apply_stderr"; and echo "$apply_stderr" >&2
                    set apply_status (string join \n -- $apply_log | jq -r '.exit_code // 1')
                    test "$apply_status" -eq 0; and set apply_status 1
            end
        end
    end

    command herdr --session "$session_name" workspace close "$bootstrap_id" >/dev/null
    set -l cleanup_status $status

    if test $apply_status -ne 0
        echo "herdr: Spreader failed; the session may contain a partial layout" >&2
        return $apply_status
    end
    if test $cleanup_status -ne 0
        echo "herdr: could not remove the Spreader bootstrap workspace" >&2
        return $cleanup_status
    end
end
