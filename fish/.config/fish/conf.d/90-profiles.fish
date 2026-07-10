status is-interactive; or return

# Backward-compatible fallback if another shell exported ZSH_PROFILE.
if not set -q DOTFILES_PROFILE
    if set -q ZSH_PROFILE
        set -gx DOTFILES_PROFILE "$ZSH_PROFILE"
    end
end

# Transitional fallback for the existing zsh-local pre file. Fish does not
# source zsh syntax; this only reads a simple "export ZSH_PROFILE=name" line.
if not set -q DOTFILES_PROFILE
    set -l zsh_pre "$HOME/.config/zsh-local/pre.zsh"
    if test -f "$zsh_pre"
        set -l zsh_profile_line (string match -r '^\s*export\s+ZSH_PROFILE=[A-Za-z0-9_-]+\s*$' <"$zsh_pre" | tail -n 1)
        set -l zsh_profile (string replace -r '^\s*export\s+ZSH_PROFILE=([A-Za-z0-9_-]+)\s*$' '$1' -- $zsh_profile_line)
        test -n "$zsh_profile"; and set -gx DOTFILES_PROFILE "$zsh_profile"
    end
end

if not set -q DOTFILES_PROFILE
        set -gx DOTFILES_PROFILE personal
end

set -l profile_dir "$HOME/.config/fish/profiles/$DOTFILES_PROFILE"
if test -d "$profile_dir"
    for f in "$profile_dir"/*.fish
        test -f "$f"; and source "$f"
    end
end

set -l local_profile "$HOME/.config/fish/local/profile.fish"
test -f "$local_profile"; and source "$local_profile"

set -l local_secrets "$HOME/.config/fish/local/secrets.fish"
test -f "$local_secrets"; and source "$local_secrets"
