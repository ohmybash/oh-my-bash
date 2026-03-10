# npm plugin

Add [oh-my-bash](https://ohmybash.github.io) integration for [npm](https://www.npmjs.com/), providing aliases for common npm workflows. Inspired by the [oh-my-zsh npm plugin](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/npm).

## Installation

Enable the plugin by adding it to your oh-my-bash `plugins` definition in `~/.bashrc`.

```sh
plugins=(npm)
```

Optionally, enable npm tab completions:

```sh
completions=(npm)
```

## Aliases

### Install

| Alias   | Command        | Description                                           |
|---------|----------------|-------------------------------------------------------|
| `npmg`  | `npm i -g`     | Install a package globally                            |
| `npmS`  | `npm i -S`     | Install and save to `dependencies`                    |
| `npmD`  | `npm i -D`     | Install and save to `devDependencies`                 |
| `npmF`  | `npm i -f`     | Force-install, bypassing the cache                    |
| `npmU`  | `npm update`   | Update all packages to their latest allowed versions  |

### Init / Info / Search

| Alias   | Command        | Description                         |
|---------|----------------|-------------------------------------|
| `npmI`  | `npm init`     | Initialise a new `package.json`     |
| `npmi`  | `npm info`     | Show information about a package    |
| `npmSe` | `npm search`   | Search the npm registry             |

### Run scripts

| Alias   | Command           | Description                    |
|---------|-------------------|--------------------------------|
| `npmst` | `npm start`       | Run the `start` script         |
| `npmt`  | `npm test`        | Run the `test` script          |
| `npmR`  | `npm run`         | Run an arbitrary script        |
| `npmrd` | `npm run dev`     | Run the `dev` script           |
| `npmrb` | `npm run build`   | Run the `build` script         |

### Publish

| Alias   | Command        | Description           |
|---------|----------------|-----------------------|
| `npmP`  | `npm publish`  | Publish the package   |

### Inspect

| Alias    | Command              | Description                               |
|----------|----------------------|-------------------------------------------|
| `npmO`   | `npm outdated`       | List outdated packages                    |
| `npmV`   | `npm -v`             | Print the npm version                     |
| `npmL`   | `npm list`           | List all installed packages               |
| `npmL0`  | `npm ls --depth=0`   | List top-level installed packages only    |

### Local binaries / npx

| Alias   | Command                                          | Description                                  |
|---------|--------------------------------------------------|----------------------------------------------|
| `npmE`  | `PATH="$(npm prefix)/node_modules/.bin:$PATH"`   | Prepend local `node_modules/.bin` to `$PATH` |
| `npmx`  | `npx`                                            | Shorthand for `npx`                          |

