# Getting Started
- [ ] Clone repository
- [ ] Run `./setup.sh --profile personal` or `./setup.sh --profile work`
- [ ] Configure `local` specific files (if needed)

# tmux configuration

`.tmux.conf` contains general configuration changes.  Any custom files that are machine specific, such as work files that shouldn't be checked into `git` can be stored in the `~/.config/tmux/local/` directory.

# Herdr configuration

The `herdr` Stow package installs `~/.config/herdr/config.toml` for both
profiles. It carries over the tmux settings that have direct Herdr equivalents:

- `Ctrl-b` remains the prefix.
- `prefix+r` reloads the configuration.
- `prefix+h/j/k/l` focuses adjacent panes.
- `prefix+%` splits right and `prefix+"` splits down.
- New panes and tabs inherit the focused pane's working directory.
- Mouse support, terminal-derived colors, immediate tab creation, and shared
  pane borders match the tmux behavior as closely as Herdr permits.

Apply changes to a running Herdr server with:

```bash
herdr config check
herdr server reload-config
```

Neovim's direct `Ctrl-h/j/k/l` integration remains configured only for tmux.
Inside Herdr, use `prefix+h/j/k/l` to move between panes.

The setup script installs
[`herdr-plugin-workspace-manager`](https://github.com/razajamil/herdr-plugin-workspace-manager).
The plugin is installed for both profiles. Its `config.yml` is managed by the
`herdr-workspace-manager` Stow package and is linked only for the `personal`
profile. Running setup with `--profile work` removes the workspace-manager
configuration link left by an earlier personal setup while preserving Herdr's
shared `config.toml`.

The required `--profile personal|work` argument is also persisted as Fish's
universal `DOTFILES_PROFILE` variable, keeping Stow selection and shell profile
selection in sync.

# Fish Configuration Layout

Fish uses its native `conf.d` autoloading with a small profile layer and ignored
machine-local overrides.

```
~/.config/fish/
├── conf.d/                         # shared configuration, autoloaded by Fish
│   ├── 00-core.fish
│   ├── 05-completions.fish
│   ├── 10-prompt.fish
│   ├── 30-keybindings.fish
│   ├── 40-history.fish
│   ├── 50-homebrew.fish
│   ├── 60-pnpm.fish
│   ├── 70-editor-ruby.fish
│   └── 90-profiles.fish           # loads the active profile
├── profiles/
│   ├── personal/                  # personal-only paths and aliases
│   └── work/                      # work-only paths and aliases
├── local/                         # gitignored machine overrides and secrets
└── config.fish                    # loads local/*.fish after conf.d
```

## Load Order

Fish automatically loads `conf.d/*.fish` in filename order before
`config.fish`:

```
conf.d/*.fish
 └── 90-profiles.fish
      └── profiles/$DOTFILES_PROFILE/*.fish
config.fish
 └── local/*.fish
```

Shared configuration belongs in `conf.d`. Personal/work differences belong in
the corresponding profile directory. Machine-specific settings and secrets
belong in `local`, which is ignored by Git and loads last so it can override
shared settings.

## Profiles

Select the active profile persistently with a Fish universal variable:

```fish
set -Ux DOTFILES_PROFILE work
```

Use `personal` to switch back:

```fish
set -Ux DOTFILES_PROFILE personal
```

If `DOTFILES_PROFILE` is unset, `personal` is used.

## Extending the Configuration

- Use `fish_add_path` or the provided `path_add` helper instead of editing `PATH` directly.
- Guard interactive-only files with `status is-interactive; or return`.
- Guard optional tool setup with `command -q tool`.
- Prefix shared files numerically when their load order matters.
- Do not manually source `conf.d`; Fish does that automatically.

## Debugging

Inspect startup time and sourced files with:

```fish
fish --profile-startup /tmp/fish-profile -i -c exit
sort -nk2 /tmp/fish-profile | tail
```

After testing `fish`, make it a login shell:

```bash
grep -qxF /opt/homebrew/bin/fish /etc/shells || echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish
```
