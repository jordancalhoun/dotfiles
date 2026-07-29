function herdr-ditches --description 'Start a Herdr session with the Ditches workspace'
    if test (count $argv) -gt 1
        echo "usage: herdr-ditches [session-name]" >&2
        return 2
    end

    set -l session_name (__herdr_default_session)
    test (count $argv) -eq 1; and set session_name $argv[1]

    __herdr_ensure_session "$session_name"; or return
    __herdr_setup_ditches "$session_name"; or return
    __herdr_focus_agent "$session_name" Ditches; or return
    command herdr session attach "$session_name"
end
