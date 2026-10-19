# fasd

The `fasd` plugin initializes [fasd](https://github.com/clvv/fasd).

## Features

- Initializes fasd with Bash aliases and completion.
- Installs fasd Bash completion support.
- Lets oh-my-bash handle the prompt hook used to update fasd's database.

## Enable

Add `fasd` to the plugins array in your `.bashrc` file:

```bash
plugins=(... fasd)
```

Reload your shell configuration after editing `.bashrc`:

```bash
source ~/.bashrc
```

## Requirements

Install `fasd` before enabling this plugin. If `fasd` is not available in your `PATH`, the plugin prints a warning and does not activate.

## Optional Logging

By default, the plugin skips the extra fasd prompt-hook processing. To enable that processing and keep its output, set `OMB_PLUGIN_FASD_SINK` before loading oh-my-bash:

```bash
OMB_PLUGIN_FASD_SINK=/tmp/fasd.log
plugins=(... fasd)
```
