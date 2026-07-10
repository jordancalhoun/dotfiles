status is-interactive; or return

set -gx EDITOR nvim

if command -q rbenv
    rbenv init - fish | source
end
