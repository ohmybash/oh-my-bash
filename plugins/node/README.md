# node plugin

Add [oh-my-bash](https://ohmybash.github.io) integration for [Node.js](https://nodejs.org/) development, providing aliases and utilities for everyday Node.js workflows. Inspired by the [oh-my-zsh node plugin](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/node).

## Installation

Enable the plugin by adding it to your oh-my-bash `plugins` definition in `~/.bashrc`.

```sh
plugins=(node)
```

## Aliases

| Alias          | Command          | Description                    |
|----------------|------------------|--------------------------------|
| `node-version` | `node --version` | Print the current Node version |

## Functions

### `node-docs [section]`

Open the Node.js API documentation for the **currently active Node.js version** in a browser. Falls back to printing the URL if no browser opener is available.

```bash
node-docs         # open the full API index
node-docs fs      # open the 'fs' module docs
node-docs http    # open the 'http' module docs
node-docs stream  # open the 'stream' module docs
```

Works with any Node.js version manager (nvm, mise, asdf, etc.) — it always reflects the version currently on your `$PATH`.

### `node-json <expression>`

Evaluate a JavaScript expression via `node -e` and pretty-print the result as JSON. Useful for quickly inspecting Node.js internals.

```bash
node-json 'process.versions'            # print all runtime versions
node-json 'process.env'                 # print environment variables
node-json 'require("os").cpus()'        # print CPU info (using require)
node-json 'require("os").cpus().length' # number of CPUs
```
