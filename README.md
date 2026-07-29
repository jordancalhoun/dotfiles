# Getting Started
- [ ] Run the bootstrap command on a new machine:

```bash
curl -fsSL https://raw.githubusercontent.com/jordancalhoun/dotfiles/main/bootstrap.sh | bash
```

The bootstrap script only creates `~/Projects`, clones this repository into
`~/Projects/dotfiles`, and starts `setup.sh`. The first setup prompt asks whether
the machine user type is `user` or `agent`.

- [ ] Choose browser/device or fine-grained-token GitHub authentication
- [ ] Configure `local` specific files (if needed)

Setup skips the GitHub prompt when `gh` is already authenticated. GitHub CLI
stores credentials in the system credential store when available and warns if
it must fall back to plaintext storage. Browser/device authentication is the
recommended choice for personal machines that access multiple organizations.
Fine-grained tokens are useful for restricted agent machines, but each token can
access resources owned by only one user or organization. Choosing fine-grained
token authentication skips the 1Password SSH setup for that setup run. Agent
machines always skip the 1Password SSH setup.

After GitHub authentication, setup offers to clone the repositories configured
for the selected user type in `scripts/repositories.sh`. Add repositories as
`OWNER/REPO` entries to `SHARED_REPOSITORIES`, `AGENT_REPOSITORIES`, or
`USER_REPOSITORIES`. Shared repositories are cloned for both user types. Setup
clones them into `~/Projects` and skips existing destinations.

On browser-authenticated personal machines, setup can configure Fish to use SSH
keys from the 1Password desktop app. It opens 1Password and pauses while you sign
in, then asks you to enable **Settings > Developer > Use the SSH Agent**. The
generated `local/10-1password-ssh-agent.fish` file is ignored by Git.

# tmux configuration

`.tmux.conf` contains general configuration changes.  Any custom files that are machine specific, such as work files that shouldn't be checked into `git` can be stored in the `~/.config/tmux/local/` directory.

# Herdr configuration

The `herdr` Stow package installs `~/.config/herdr/config.toml`. It carries over
the tmux settings that have direct Herdr equivalents:

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
[`herdr-spreader`](https://github.com/yuk1ty/herdr-spreader). Its declarative
workspace layout is managed by the `herdr-spreader` Stow package. The `stampeed`
Fish function applies that layout only when its named session is empty, then
attaches to the session. Subsequent calls attach without creating duplicate
workspaces. Pass a session name to use a separate named session. Add `--force`
to stop and delete that session before rebuilding it; without a session name,
`stampeed --force` rebuilds Herdr's implicit `default` session. Herdr does not
support deleting that special session, so the forced path stops it and removes
only its saved `session.json` topology before rebuilding. Run a forced rebuild
from outside the session being replaced.

`herdr-mini` accepts the same optional session name and `--force` flag. A forced
remote launch first runs `stampeed SESSION --force --prepare-only` on the mini
over SSH, waits for that connection to close, then attaches with Herdr's remote
thin client.

# Fish Configuration Layout

Fish uses its native `conf.d` autoloading with ignored machine-local overrides.

```
~/.config/fish/
├── conf.d/                         # shared configuration, autoloaded by Fish
│   ├── 00-core.fish
│   ├── 05-completions.fish
│   ├── 10-prompt.fish
│   ├── 30-keybindings.fish
│   ├── 50-homebrew.fish
│   ├── 60-pnpm.fish
│   └── 70-editor-ruby.fish
├── local/                         # gitignored machine overrides and secrets
└── config.fish                    # loads local/*.fish after conf.d
```

## Load Order

Fish automatically loads `conf.d/*.fish` in filename order before
`config.fish`:

```
conf.d/*.fish
config.fish
 └── local/*.fish
```

Shared configuration belongs in `conf.d`. Machine-specific settings and secrets
belong in `local`, which is ignored by Git and loads last so it can override
shared settings.

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
