#! bash oh-my-bash.module
which register-python-argcomplete &> /dev/null \
  && eval "$(register-python-argcomplete conda)" \
  || echo "Please install argcomplete to use conda completion" > /dev/null
