status is-interactive; or return

# Select a profile persistently with `set -Ux DOTFILES_PROFILE personal|work`.
set -q DOTFILES_PROFILE; or set -gx DOTFILES_PROFILE personal

set -l profile_dir "$HOME/.config/fish/profiles/$DOTFILES_PROFILE"
if test -d "$profile_dir"
    for f in "$profile_dir"/*.fish
        test -f "$f"; and source "$f"
    end
end
