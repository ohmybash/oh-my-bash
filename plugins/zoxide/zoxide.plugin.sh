#!/usr/bin/env bash

# Check if zoxide is installed
if [ -x "$(command -v zoxide)" ]; then
    eval "$(zoxide init bash)"
else
    echo '[oh-my-bash] zoxide not found, please install it from https://github.com/ajeetdsouza/zoxide'
fi
