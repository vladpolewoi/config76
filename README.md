# config76

Dotfiles and machine setup for macOS and Arch Linux.

## Structure

```
config76/
  .config/       Shared configs: nvim, tmux, ghostty
  .local/        Shared scripts
  .zshrc         Base shell config (sourced by machine ~/.zshrc)
  mac/           macOS-specific setup
  arch/          Arch Linux-specific setup
```

## Setup

### macOS
```bash
cd mac
bash install.sh   # interactive — pick what to install
bash env.sh       # symlink dotfiles and configs
```

### Arch
```bash
cd arch
bash env.sh       # copy dotfiles and configs
```

---

## Required Secrets

Some configs use environment variables instead of hardcoded values.
Each platform has a `secrets.env.example` — copy it to `secrets.env` and fill in real values.
`secrets.env` is gitignored and never committed.

### arch/secrets.env

| Variable | Description | Example |
|---|---|---|
| `DSD_CALENDAR_HOST` | DocSpace calendar server IP | `185.91.xx.xx` |
| `DSD_DEV_HOST` | DocSpace dev server IP | `89.208.xx.xx` |

```bash
cp arch/secrets.env.example arch/secrets.env
# edit arch/secrets.env with real values
```

### Machine ~/.zshrc

These go in the machine-specific section of `~/.zshrc` (below the `source config76/.zshrc` line):

| Variable | Description |
|---|---|
| `NODE_AUTH_TOKEN` | GitHub PAT with `read:packages` scope — for `@lasso-security` npm packages |

```bash
# ~/.zshrc (machine-specific section)
export NODE_AUTH_TOKEN="ghp_..."
```

Generate a token at: github.com/settings/tokens → classic → `read:packages`
