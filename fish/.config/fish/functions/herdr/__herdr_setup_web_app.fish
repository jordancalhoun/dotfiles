function __herdr_setup_web_app --argument-names session_name repo workspace_label agent_name
    __herdr_setup_project \
        "$session_name" \
        "$repo" \
        "$workspace_label" \
        "$agent_name" \
        web-app
end
