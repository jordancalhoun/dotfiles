status is-interactive; or return

set -gx PNPM_HOME "$HOME/Library/pnpm"
path_add "$PNPM_HOME"

command -q pnpm; and alias pn=pnpm
