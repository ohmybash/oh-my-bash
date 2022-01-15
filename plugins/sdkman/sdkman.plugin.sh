#! bash oh-my-bash.module

# Set SDKMAN_DIR if it isn't already defined
[[ ${SDKMAN_DIR-} ]] || export SDKMAN_DIR=~/.sdkman

# Try to load sdk only if the command is not available
if ! _omb_util_command_exists sdk && [[ -s $SDKMAN_DIR/bin/sdkman-init.sh ]]; then
  source "$SDKMAN_DIR/bin/sdkman-init.sh"
fi
