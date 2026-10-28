#! bash oh-my-bash.module

# Check if direnv is installed
if _omb_util_command_exists direnv; then
  # Set up direnv shell hooks
  eval -- "$(direnv hook bash)"
else
  _omb_util_print '[oh-my-bash] direnv not found, please install it from https://github.com/direnv/direnv' >&2
fi
