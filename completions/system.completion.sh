#! bash oh-my-bash.module

# Loads one of the system's Bash-completion modules.

# If bash-completion is already enabled (by e.g. /etc/bash.bashrc sourced from
# /etc/profile or directly executed by Bash), we skip loading bash-completion.
[[ ${BASH_COMPLETION_VERSINFO-} ]] && return 0

# We skip loading bash-completion in the POSIX mode.  Older versions of
# bash-completion do not work in the POSIX mode.
shopt -oq posix && return 0

# If Homebrew is installed (OS X), its Bash completion module is loaded.
if is_os darwin && _omb_util_command_exists brew; then
  BREW_PREFIX=$(brew --prefix)

  # homebrew/versions/bash-completion2 (required for projects.completion.bash)
  # is installed to this path
  if [[ -f "$BREW_PREFIX"/share/bash-completion/bash_completion ]]; then
    source "$BREW_PREFIX"/share/bash-completion/bash_completion
    return "$?"
  fi

  if [[ -f "$BREW_PREFIX"/etc/bash_completion ]]; then
    source "$BREW_PREFIX"/etc/bash_completion
    return "$?"
  fi
fi

if [[ -f /usr/share/bash-completion/bash_completion ]]; then
  # bash-completion v2 is installed at this location
  source /usr/share/bash-completion/bash_completion
  return "$?"
elif [[ -f /etc/bash_completion ]]; then
  # bash-completion v1 is installed at this location
  source /etc/bash_completion
  return "$?"
fi

if [[ -f /etc/profile.d/bash_completion.sh ]]; then
  # Some distribution makes use of a profile.d script to import completion.
  source /etc/profile.d/bash_completion.sh
  return "$?"
fi
