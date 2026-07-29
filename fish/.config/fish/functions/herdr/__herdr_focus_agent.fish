function __herdr_focus_agent --argument-names session_name workspace_label
    set -l snapshot (command herdr --session "$session_name" api snapshot); or return
    set -l workspace_id (string join \n -- $snapshot | jq -r --arg label "$workspace_label" '.result.snapshot.workspaces[] | select(.label == $label) | .workspace_id' | head -n 1)
    set -l code_tab (string join \n -- $snapshot | jq -r --arg workspace "$workspace_id" '.result.snapshot.tabs[] | select(.workspace_id == $workspace and .label == "code") | .tab_id' | head -n 1)

    if test -z "$workspace_id" -o -z "$code_tab"
        echo "herdr: could not find the code tab for '$workspace_label'" >&2
        return 1
    end

    command herdr --session "$session_name" workspace focus "$workspace_id" >/dev/null; or return
    command herdr --session "$session_name" tab focus "$code_tab" >/dev/null; or return

    # The agent is the left pane. This moves left when the editor was focused
    # and harmlessly does nothing when the agent was already focused.
    command herdr --session "$session_name" pane focus --current --direction left >/dev/null 2>&1
    return 0
end
