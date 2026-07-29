function __herdr_ensure_session --argument-names session_name
    if test -z "$session_name"
        echo "__herdr_ensure_session: a session name is required" >&2
        return 2
    end

    command herdr --session "$session_name" status server 2>/dev/null | string match -q 'status: running'; and return

    command herdr --session "$session_name" server >/dev/null 2>&1 &
    disown $last_pid

    for attempt in (seq 1 50)
        command herdr --session "$session_name" status server 2>/dev/null | string match -q 'status: running'; and return
        sleep 0.1
    end

    echo "herdr: timed out starting session '$session_name'" >&2
    return 1
end
