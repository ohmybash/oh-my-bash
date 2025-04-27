#! bash oh-my-bash.module

# Check if zoxide is installed
if _omb_util_command_exists zoxide; then
  eval -- "$(zoxide init bash)"
else
  _omb_util_print '[oh-my-bash] zoxide not found, please install it from https://github.com/ajeetdsouza/zoxide' >&2
fi
