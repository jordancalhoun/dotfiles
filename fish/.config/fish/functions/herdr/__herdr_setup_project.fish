function __herdr_setup_project --argument-names session_name repo workspace_label agent_name project_kind
    if test -z "$session_name" -o -z "$repo" -o -z "$workspace_label" -o -z "$agent_name"
        echo "__herdr_setup_project: session, repo, workspace label, and agent name are required" >&2
        return 2
    end

    if not contains -- "$project_kind" web-app code
        echo "__herdr_setup_project: unsupported project kind '$project_kind'" >&2
        return 2
    end

    if not test -d "$repo"
        echo "herdr: repository not found: $repo" >&2
        return 1
    end

    set -l workspace_json (command herdr --session "$session_name" workspace list); or return
    set -l workspace_id (string join \n -- $workspace_json | jq -r --arg label "$workspace_label" '.result.workspaces[] | select(.label == $label) | .workspace_id' | head -n 1)

    if test -z "$workspace_id"
        command herdr --session "$session_name" workspace create \
            --cwd "$repo" \
            --label "$workspace_label" \
            --no-focus >/dev/null; or return

        set workspace_json (command herdr --session "$session_name" workspace list); or return
        set workspace_id (string join \n -- $workspace_json | jq -r --arg label "$workspace_label" '.result.workspaces[] | select(.label == $label) | .workspace_id' | head -n 1)
        if test -z "$workspace_id"
            echo "herdr: created '$workspace_label' but did not receive its workspace ID" >&2
            return 1
        end
    end

    # Reconcile an existing workspace as well as scaffolding a new one. This
    # makes a rerun recover cleanly if an earlier command stopped halfway.
    set -l snapshot (command herdr --session "$session_name" api snapshot); or return
    set -l code_tab (string join \n -- $snapshot | jq -r --arg workspace "$workspace_id" '.result.snapshot.tabs[] | select(.workspace_id == $workspace and .label == "code") | .tab_id' | head -n 1)

    if test -z "$code_tab"
        __herdr_add_code_tab "$session_name" "$repo" "$workspace_id" "$agent_name"; or return
    else
        set -l agent_pane (string join \n -- $snapshot | jq -r --arg tab "$code_tab" '.result.snapshot.panes[] | select(.tab_id == $tab and .label == "agent") | .pane_id' | head -n 1)
        set -l running_agent (string join \n -- $snapshot | jq -r --arg pane "$agent_pane" '.result.snapshot.panes[] | select(.pane_id == $pane) | .agent // empty')
        if test -n "$agent_pane" -a -z "$running_agent"
            __herdr_start_agent "$session_name" "$agent_pane" "$agent_name"; or return
        end
    end

    set snapshot (command herdr --session "$session_name" api snapshot); or return

    if test "$project_kind" = web-app
        set -l server_tab (string join \n -- $snapshot | jq -r --arg workspace "$workspace_id" '.result.snapshot.tabs[] | select(.workspace_id == $workspace and .label == "server") | .tab_id' | head -n 1)
        if test -z "$server_tab"
            __herdr_add_server_tab "$session_name" "$repo" "$workspace_id"; or return
        end
    end

    set snapshot (command herdr --session "$session_name" api snapshot); or return
    set -l git_tab (string join \n -- $snapshot | jq -r --arg workspace "$workspace_id" '.result.snapshot.tabs[] | select(.workspace_id == $workspace and .label == "git") | .tab_id' | head -n 1)
    if test -z "$git_tab"
        __herdr_add_git_tab "$session_name" "$repo" "$workspace_id"; or return
    end
end
