status is-interactive; or return

if command -q pnpm
    alias pn=pnpm
end

set -gx PNPM_HOME "$HOME/Library/pnpm"
path_add "$PNPM_HOME"
