function __herdr_start_agent --argument-names session_name pane_id agent_name
    set -l last_error

    # Newly created terminals can appear in the API just before their shell is
    # ready. Retry the transient agent_pane_busy response for up to five seconds.
    for attempt in (seq 1 25)
        set last_error (command herdr --session "$session_name" agent start "$agent_name" \
            --kind opencode \
            --pane "$pane_id" 2>&1)
        set -l command_status $status

        if test $command_status -eq 0
            return
        end

        string join \n -- $last_error | string match -q '*agent_pane_busy*'; or begin
            string join \n -- $last_error >&2
            return $command_status
        end

        sleep 0.2
    end

    string join \n -- $last_error >&2
    return 1
end
