function stampeed --description 'Start a Herdr session with all configured workspaces'
    if test (count $argv) -gt 1
        echo "usage: stampeed [session-name]" >&2
        return 2
    end

    set -l session_name (__herdr_default_session)
    test (count $argv) -eq 1; and set session_name $argv[1]

    __herdr_ensure_session "$session_name"; or return

    # Add each new __herdr_setup_* function here.
    __herdr_setup_codecarton "$session_name"; or return
    __herdr_setup_devote "$session_name"; or return
    __herdr_setup_one16 "$session_name"; or return
    __herdr_setup_ditches "$session_name"; or return
    __herdr_setup_dotfiles "$session_name"; or return

    __herdr_focus_agent "$session_name" codecarton.com-v2; or return
    command herdr session attach "$session_name"
end
