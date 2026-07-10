status is-interactive; or return

if command -q pnpm
    alias pn=pnpm
    # Set global variable and add to the PATH
    set -gx PNPM_HOME "$HOME/Library/pnpm"
    path_add "$PNPM_HOME"
end
