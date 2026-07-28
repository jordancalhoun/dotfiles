# Getting Started
- [ ] Clone repository
- [ ] Run `setup.sh`
- [ ] Configure `local` specific files (if needed)

# tmux configuration

`.tmux.conf` contains general configuration changes.  Any custom files that are machine specific, such as work files that shouldn't be checked into `git` can be stored in the `~/.config/tmux/local/` directory.

# Zsh Configuration Layout

This repository contains a **modular, profile-aware Zsh configuration** designed to be:

- predictable (deterministic load order)
- portable (safe across machines and OSes)
- secure (secrets and work-specific logic are never committed)
- easy to extend (add/remove features without editing `.zshrc`)

---

## Overview

Zsh configuration is split into **four layers**, each with a single responsibility:

```
~/.config/zsh-local/pre   → decides environment & profile  
conf.d                    → shared, always-on configuration  
profiles                  → work / personal behavior  
~/.config/zsh-local/post  → secrets & machine overrides  
```

---

## Directory Structure

```
~/.config/zsh/
├── zshrc                     # minimal loader
│
├── conf.d/                   # shared base configuration
│   ├── 00-core.zsh
│   ├── 10-homebrew.zsh
│   ├── 20-prompt-starship.zsh
│   ├── 30-zinit.zsh
│   ├── 40-keybindings.zsh
│   ├── 50-history.zsh
│   ├── 60-completion.zsh
│   ├── 70-pnpm.zsh
│   ├── 80-ruby-rbenv.zsh
│   ├── 90-path-tools.zsh
│   └── 95-profiles.zsh       # loads the active profile
│
├── profiles/                 # profile-specific logic
│   ├── work/
│   │   ├── 10-functions.zsh
│   │   ├── 20-aliases.zsh
│   │   └── 30-paths.zsh
│   │
│   └── personal/
│       ├── 10-functions.zsh
│       ├── 20-aliases.zsh
│       └── 30-paths.zsh
│
~/.config/
└── zsh-local/                # machine-specific
    ├── pre.zsh               # decides profile (hostname, VPN, etc.)
    └── post/                 # secrets & overrides, loads any files with `.zsh` extension
```

---

## Load Order

The order below is intentional:
```
zshrc  
 ├── local/pre*.zsh  
 ├── conf.d/*.zsh  
 ├── conf.d/95-profiles.zsh  
 │    └── profiles/$ZSH_PROFILE/*.zsh  
 └── local/post/*.zsh  
```

---

## Profiles

Profiles allow separation between **work** and **personal** environments.

### Selecting a profile

Set in `~/.config.zsh-local/pre.zsh`:

```bash
export ZSH_PROFILE=work
```

Or auto-select:

```bash
case "$(hostname -s)" in
  work-*) export ZSH_PROFILE=work ;;
  *)      export ZSH_PROFILE=personal ;;
esac
```

If unset, `personal` is used.

---

## Best Practices

- Use `path_add` to avoid duplicate PATH entries
- Guard interactive-only code with `[[ -o interactive ]]`
- Guard tool-specific config with `command -v toolname`

---

## Debugging

Enable tracing:

```bash
set -x
```

Or trace loads:

```bash
echo "loading: $f"
```

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

Alternatively, keep the login shell as zsh and configure Ghostty to launch `/opt/homebrew/bin/fish`.
