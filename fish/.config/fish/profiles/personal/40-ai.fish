# opencode
path_add "$HOME/.opencode/bin"

if command -q opencode
    alias code=opencode
end

# start a remote herdr session on Mac mini
function herdr-mini
    herdr --remote ssh://mini
end
