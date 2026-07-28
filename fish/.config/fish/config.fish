# Load machine-specific configuration before local post overrides.
set -l fish_local_pre "$HOME/.config/fish-local/pre"
if test -d "$fish_local_pre"
    for f in "$fish_local_pre"/*.fish
        test -f "$f"; and source "$f"
    end
end

# Fish automatically loads ~/.config/fish/conf.d/*.fish before config.fish.

# Local post files: overrides, secrets, and machine-specific functions.
set -l fish_local_post "$HOME/.config/fish-local/post"
if test -d "$fish_local_post"
    for f in "$fish_local_post"/*.fish
        test -f "$f"; and source "$f"
    end
end
