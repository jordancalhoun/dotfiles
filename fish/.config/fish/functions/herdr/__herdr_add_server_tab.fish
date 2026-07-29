function __herdr_add_server_tab --argument-names session_name repo workspace_id
    command herdr --session "$session_name" tab create \
        --workspace "$workspace_id" \
        --cwd "$repo" \
        --label server \
        --env PORT=3000 \
        --no-focus >/dev/null; or return

    set -l snapshot (command herdr --session "$session_name" api snapshot); or return
    set -l server_tab (string join \n -- $snapshot | jq -r --arg workspace "$workspace_id" '.result.snapshot.tabs[] | select(.workspace_id == $workspace and .label == "server") | .tab_id' | head -n 1)
    set -l pane_json (command herdr --session "$session_name" pane list --workspace "$workspace_id"); or return
    set -l dev_pane (string join \n -- $pane_json | jq -r --arg tab "$server_tab" '.result.panes[] | select(.tab_id == $tab) | .pane_id' | head -n 1)
    command herdr --session "$session_name" pane rename "$dev_pane" dev >/dev/null; or return
    command herdr --session "$session_name" pane split "$dev_pane" \
        --direction down \
        --ratio 0.7 \
        --cwd "$repo" \
        --no-focus >/dev/null; or return

    set pane_json (command herdr --session "$session_name" pane list --workspace "$workspace_id"); or return
    set -l shell_pane (string join \n -- $pane_json | jq -r --arg tab "$server_tab" --arg dev "$dev_pane" '.result.panes[] | select(.tab_id == $tab and .pane_id != $dev) | .pane_id' | head -n 1)
    command herdr --session "$session_name" pane rename "$shell_pane" shell >/dev/null; or return

    command herdr --session "$session_name" pane run "$dev_pane" pnpm dev >/dev/null; or return
end
