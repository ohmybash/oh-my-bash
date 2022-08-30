#! bash oh-my-bash.module
_omb_util_binary_exists register-python-argcomplete \
  && eval "$(register-python-argcomplete conda)" \
  || echo "Please install argcomplete to use conda completion"
