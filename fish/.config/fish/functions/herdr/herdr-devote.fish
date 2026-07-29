function herdr-devote --description 'Start a Herdr session with the Devote workspace'
    if test (count $argv) -gt 1
        echo "usage: herdr-devote [session-name]" >&2
        return 2
    end

    set -l session_name (__herdr_default_session)
    test (count $argv) -eq 1; and set session_name $argv[1]

    __herdr_ensure_session "$session_name"; or return
    __herdr_setup_devote "$session_name"; or return
    __herdr_focus_agent "$session_name" Devote; or return
    command herdr session attach "$session_name"
end
