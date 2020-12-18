#!/usr/bin/env bash

set -e

tmpdir=$(mktemp -d)

export OSH="$tmpdir/path with space"
export HOME="$tmpdir/home with space"
mkdir -p "$HOME"

OSH_REPOSITORY="$PWD" ./tools/install.sh

source "$HOME/.bashrc"

set | grep -aE "^OSH"

if [[ "$OSH_THEME" == "font" ]]; then
  echo "Installation succeeded"
else
  echo "Installation failed, \$OSH_THEME is not set to 'font'"
  exit 1
fi
