# Define anything that needs to happen before shared config loads.
# Set DOTFILES_PROFILE here from ~/.config/fish-local/pre/*.fish when needed.
set -l fish_local_pre "$HOME/.config/fish-local/pre"
if test -d "$fish_local_pre"
    for f in "$fish_local_pre"/*.fish
        test -f "$f"; and source "$f"
    end
end

# Shared configuration.
set -l fish_conf_d "$HOME/.config/fish/conf.d"
if test -d "$fish_conf_d"
    for f in "$fish_conf_d"/*.fish
        test -f "$f"; and source "$f"
    end
end

# Local post files: overrides, secrets, and machine-specific functions.
set -l fish_local_post "$HOME/.config/fish-local/post"
if test -d "$fish_local_post"
    for f in "$fish_local_post"/*.fish
        test -f "$f"; and source "$f"
    end
end
