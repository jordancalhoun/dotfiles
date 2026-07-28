# Fish automatically loads ~/.config/fish/conf.d/*.fish before config.fish.
# Files in local/ are gitignored machine-specific overrides and secrets.
set -l fish_local "$HOME/.config/fish/local"
if test -d "$fish_local"
    for f in "$fish_local"/*.fish
        test -f "$f"; and source "$f"
    end
end
