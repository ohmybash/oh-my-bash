# asdf plugin

Add [oh-my-bash](https://ohmybash.github.io) integration with [asdf](https://github.com/asdf-vm/asdf), the extendable version manager, with support for Ruby, Node.js, Elixir, Erlang and more.

## Installation

1. [Install asdf](https://github.com/asdf-vm/asdf#setup) by running the following:
    ``` bash
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf
    ```

2. Enable the plugin by adding it to your oh-my-bash `plugins` definition in `~/.bashrc`.
    ``` sh
    plugins=(asdf)
    ```

2. Enable the completions by adding it to your oh-my-bash `completions` definition in `~/.bashrc`.
    ``` sh
    completions=(asdf)
    ```

## Usage

See the [asdf usage documentation](https://github.com/asdf-vm/asdf#usage) for information on how to use asdf:

``` bash
asdf plugin add nodejs
asdf install nodejs latest
```
