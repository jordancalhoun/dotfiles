function __herdr_add_git_tab --argument-names session_name repo workspace_id
    command herdr --session "$session_name" tab create \
        --workspace "$workspace_id" \
        --cwd "$repo" \
        --label git \
        --no-focus >/dev/null; or return

    set -l snapshot (command herdr --session "$session_name" api snapshot); or return
    set -l git_tab (string join \n -- $snapshot | jq -r --arg workspace "$workspace_id" '.result.snapshot.tabs[] | select(.workspace_id == $workspace and .label == "git") | .tab_id' | head -n 1)
    set -l pane_json (command herdr --session "$session_name" pane list --workspace "$workspace_id"); or return
    set -l git_pane (string join \n -- $pane_json | jq -r --arg tab "$git_tab" '.result.panes[] | select(.tab_id == $tab) | .pane_id' | head -n 1)
    command herdr --session "$session_name" pane rename "$git_pane" lazygit >/dev/null; or return
    command herdr --session "$session_name" pane run "$git_pane" lazygit >/dev/null; or return
end
