#! bash oh-my-bash.module

# Check if virtualenvwrapper is installed
if _omb_util_command_exists virtualenvwrapper.sh; then
  # Source the virtualenvwrapper script
  source virtualenvwrapper.sh
else
  _omb_util_print '[oh-my-bash] virtualenvwrapper not found, please install it from https://github.com/python-virtualenvwrapper/virtualenvwrapper' >&2
fi
