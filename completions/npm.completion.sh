#! bash oh-my-bash.module

# npm (Node Package Manager) completion
# https://docs.npmjs.com/cli/completion

if _omb_util_command_exists npm
then
  eval "$(npm completion)"
fi
