# fzf plugin

The fzf plugin enables [fzf](https://github.com/junegunn/fzf) key bindings and fuzzy completion in Bash.

## Installation

### Install fzf

**Package manager / mise / asdf:**

```bash
# Homebrew
brew install fzf

# mise
mise use -g fzf
```

**Git (official method):**

```bash
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --no-update-rc  # skip the ~/.bashrc modification, the plugin handles it
```

> **Note:** If you installed fzf via git, pass `--no-update-rc` to the installer (or answer *No* when asked to update `.bashrc`). The plugin automatically adds `~/.fzf/bin` to your `$PATH` — no need for `source ~/.fzf.bash`.

### Enable the plugin

```sh
plugins=(fzf)
```

## Supported installation locations

The plugin searches for fzf in the following locations, in order:

1. Already in `$PATH` (package managers, mise, asdf, manual installs)
2. `~/.fzf/bin` (git clone install)
3. `${XDG_CONFIG_HOME:-$HOME/.config}/fzf/bin`

## Key bindings

Once active, fzf provides these shell key bindings:

| Binding     | Description                                |
|-------------|--------------------------------------------|
| `Ctrl+T`    | Paste selected file paths into the command |
| `Ctrl+R`    | Search command history                     |
| `Alt+C`     | `cd` into the selected directory           |
