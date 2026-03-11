# mise plugin

Add [oh-my-bash](https://ohmybash.github.io) integration with [mise](https://mise.jdx.dev), a polyglot tool version manager for Node.js, Python, Ruby, Go, and more. mise is a faster, drop-in replacement for [asdf](https://asdf-vm.com) that also supports `.tool-versions` files.

## Installation

1. [Install mise](https://mise.jdx.dev/getting-started.html) by running the following:

    ```bash
    curl https://mise.run | sh
    ```

2. Enable the plugin by adding it to your oh-my-bash `plugins` definition in `~/.bashrc`.

    ```sh
    plugins=(mise)
    ```

The plugin resolves the mise binary automatically — no manual `eval` line in `~/.bashrc` is needed. It checks the following locations in order:

1. `mise` on `$PATH` (system package managers: apt, brew, dnf, pacman, etc.)
2. `$MISE_INSTALL_PATH` (custom install path set at install time)
3. `~/.local/bin/mise` (default location for `curl https://mise.run | sh`)

## Configuration

### Quiet mode

By default, mise may print a message when activated. To suppress this, set the following variable **before** the `source` line in your `~/.bashrc`:

```sh
OMB_PLUGIN_MISE_QUIET=true
```

## Aliases

All aliases target the resolved mise binary, so they work regardless of whether mise is on `$PATH`.

| Alias  | Command           | Description                              |
|--------|-------------------|------------------------------------------|
| `mi`   | `mise install`    | Install tool versions defined in config  |
| `mu`   | `mise use`        | Set a tool version in the config file    |
| `mr`   | `mise run`        | Run a task defined in `mise.toml`        |
| `mex`  | `mise exec`       | Run a command in the mise environment    |
| `mls`  | `mise ls`         | List installed tool versions             |
| `mlsr` | `mise ls-remote`  | List available remote versions           |

## Usage

See the [mise documentation](https://mise.jdx.dev/getting-started.html) for full usage:

```bash
mi node@22          # mise install node@22
mu node@lts         # mise use node@lts
mex -- node --version
```
