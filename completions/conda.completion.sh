#! bash oh-my-bash.module
if _omb_util_binary_exists register-python-argcomplete; then
  eval "$(register-python-argcomplete conda)"
elif _omb_util_binary_exists register-python-argcomplete3; then
  eval "$(register-python-argcomplete3 conda)"
elif _omb_util_binary_exists register-python-argcomplete2; then
  eval "$(register-python-argcomplete2 conda)"
else
  echo "Please install argcomplete to use conda completion" >&2
fi
