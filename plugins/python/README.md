# python plugin

Add [oh-my-bash](https://ohmybash.github.io) integration for [Python](https://www.python.org/) development, providing aliases and utilities for everyday workflows including virtual environment management, pip, and project housekeeping. Inspired by the [oh-my-zsh python plugin](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/python).

## Installation

Enable the plugin by adding it to your oh-my-bash `plugins` definition in `~/.bashrc`.

```sh
plugins=(python)
```

## Configuration

Set these variables **before** the `source "$OSH/oh-my-bash.sh"` line in your `~/.bashrc`.

| Variable                       | Default   | Description                                            |
|--------------------------------|-----------|--------------------------------------------------------|
| `OMB_PLUGIN_PYTHON_VENV_NAME`  | `venv`    | Default venv directory name used by `vrun` and `mkv`   |
| `OMB_PLUGIN_PYTHON_AUTO_VRUN`  | _(unset)_ | Set to `true` to auto-activate venvs on `cd`           |

## Aliases

### General

| Alias      | Command                    | Description                                              |
|------------|----------------------------|----------------------------------------------------------|
| `py`       | `python3`                  | Shorthand for python3 (if `py` is not already installed) |
| `pyfind`   | `find . -name "*.py"`      | Find all Python files in current tree                    |
| `pygrep`   | `grep -rn --include="*.py"`| Search inside Python files                               |
| `pyserver` | `python3 -m http.server`   | Serve current directory over HTTP                        |

### pip

| Alias    | Command                            | Description                              |
|----------|------------------------------------|------------------------------------------|
| `pipi`   | `pip install`                      | Install a package                        |
| `pipu`   | `pip uninstall`                    | Uninstall a package                      |
| `pipup`  | `pip install --upgrade`            | Upgrade a package                        |
| `pipr`   | `pip install -r requirements.txt`  | Install from requirements.txt            |
| `pipf`   | `pip freeze`                       | Print installed packages                 |
| `pipfr`  | `pip freeze > requirements.txt`    | Save installed packages to requirements  |
| `pipls`  | `pip list`                         | List installed packages                  |
| `pipout` | `pip list --outdated`              | List outdated packages                   |

## Functions

### `pyclean [dir...]`

Remove compiled bytecode files and cache directories (`__pycache__`, `.mypy_cache`, `.pytest_cache`) from the given directories, or the current directory if none are specified.

```bash
pyclean           # clean current directory
pyclean src tests # clean specific directories
```

### `vrun [name]`

Activate a virtual environment by name. If no name is given, searches for the first existing directory in `$OMB_PLUGIN_PYTHON_VENV_NAME`, `venv`, `.venv` (in that order).

```bash
vrun          # auto-detect and activate
vrun .venv    # activate a specific venv
```

### `mkv [name]`

Create a new virtual environment with `python3 -m venv` and immediately activate it. Defaults to `$OMB_PLUGIN_PYTHON_VENV_NAME`.

```bash
mkv           # create and activate ./venv
mkv .venv     # create and activate ./.venv
```

## Auto-activate venv

When `OMB_PLUGIN_PYTHON_AUTO_VRUN=true`, the plugin overrides `cd` to automatically activate a virtual environment when you enter a directory that contains one, and deactivate it when you leave.

```sh
# ~/.bashrc (before sourcing oh-my-bash)
OMB_PLUGIN_PYTHON_AUTO_VRUN=true
```
