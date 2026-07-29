function __herdr_add_code_tab --argument-names session_name repo workspace_id agent_name
    # A new workspace already contains the tab and pane used for the code tab.
    set -l workspace_info (command herdr --session "$session_name" workspace get "$workspace_id"); or return
    set -l code_tab (string join \n -- $workspace_info | jq -r '.result.workspace.active_tab_id')
    set -l pane_json (command herdr --session "$session_name" pane list --workspace "$workspace_id"); or return
    set -l agent_pane (string join \n -- $pane_json | jq -r --arg tab "$code_tab" '.result.panes[] | select(.tab_id == $tab) | .pane_id' | head -n 1)

    command herdr --session "$session_name" tab rename "$code_tab" code >/dev/null; or return
    command herdr --session "$session_name" pane rename "$agent_pane" agent >/dev/null; or return
    command herdr --session "$session_name" pane split "$agent_pane" \
        --direction right \
        --cwd "$repo" \
        --no-focus >/dev/null; or return

    set pane_json (command herdr --session "$session_name" pane list --workspace "$workspace_id"); or return
    set -l editor_pane (string join \n -- $pane_json | jq -r --arg tab "$code_tab" --arg agent "$agent_pane" '.result.panes[] | select(.tab_id == $tab and .pane_id != $agent) | .pane_id' | head -n 1)
    command herdr --session "$session_name" pane rename "$editor_pane" editor >/dev/null; or return

    command herdr --session "$session_name" pane run "$editor_pane" nvim >/dev/null; or return
    __herdr_start_agent "$session_name" "$agent_pane" "$agent_name"; or return
end
