#!/usr/bin/env bash

# Set SDKMAN_DIR if it isn't already defined
[[ ${SDKMAN_DIR-} ]] || export SDKMAN_DIR=~/.sdkman

# Try to load sdk only if the command is not available
if ! type_exists sdk && [[ -s $SDKMAN_DIR/bin/sdkman-init.sh ]]; then
  source "$SDKMAN_DIR/bin/sdkman-init.sh"
fi
