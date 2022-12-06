# nvm plugin

This plugin automatically source nvm[1]

## Installation

### Install nvm

Lets install[2] the nvm without updaing shell config!

```bash
export NVM_DIR="$HOME/.nvm" && (
  git clone https://github.com/nvm-sh/nvm.git "$NVM_DIR"
  cd "$NVM_DIR"
  git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
) && \. "$NVM_DIR/nvm.sh"
```

### Include nvm as plugin

```bash
plugins=(
  git
  nvm
)
```

## nvm completion configuration

```bash
completions=(
  git
  composer
  ssh
  nvm
)
```

## `.nvmrc` autoload

If set, the plugin will automatically load a node version when it finds a
`.nvmrc` file[3] in the current working directory indicating which node version to load.
This can be done by adding the following to your `.bashrc`:

```bash
OMB_PLUGIN_NVM_AUTO_USE=true
```

[1]: https://github.com/nvm-sh/nvm
[2]: https://github.com/nvm-sh/nvm#manual-install
[3]: https://github.com/nvm-sh/nvm#nvmrc
