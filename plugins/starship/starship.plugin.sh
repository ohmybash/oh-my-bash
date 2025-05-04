#! bash oh-my-bash.module

# Check if starship is installed
if _omb_util_command_exists starship; then
  # ignore oh-my-bash theme
  unset -v OSH_THEME
  eval -- "$(starship init bash)"
else
  _omb_util_print '[oh-my-bash] starship not found, please install it from https://github.com/starship/starship' >&2
fi
