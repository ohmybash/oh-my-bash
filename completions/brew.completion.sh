#! bash oh-my-bash.module
if _omb_util_command_exists brew; then
  _omb_completion_brew_prefix=$(brew --prefix)
  if [[ $_omb_completion_brew_prefix ]]; then
    if [[ -f $_omb_completion_brew_prefix/etc/bash_completion ]]; then
      source "$_omb_completion_brew_prefix"/etc/bash_completion
    fi

    if [[ -f $_omb_completion_brew_prefix/Library/Contributions/brew_bash_completion.sh ]]; then
      source "$_omb_completion_brew_prefix"/Library/Contributions/brew_bash_completion.sh
    fi
  fi
  unset -v _omb_completion_brew_prefix
fi
