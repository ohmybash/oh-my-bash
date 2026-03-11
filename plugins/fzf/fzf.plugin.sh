#! bash oh-my-bash.module
# Description: Integrate fzf (https://github.com/junegunn/fzf) key bindings and fuzzy completion

# -- Locate fzf ---------------------------------------------------------------
# Support common installation methods:
#   1. Already in $PATH (package manager, mise/asdf, manual)
#   2. Git install: ~/.fzf/bin
#   3. XDG config dir: ~/.config/fzf/bin (less common)
if ! _omb_util_command_exists fzf; then
  if [[ -x $HOME/.fzf/bin/fzf ]]; then
    PATH="${PATH:+$PATH:}$HOME/.fzf/bin"
  elif [[ -x ${XDG_CONFIG_HOME:-$HOME/.config}/fzf/bin/fzf ]]; then
    PATH="${PATH:+$PATH:}${XDG_CONFIG_HOME:-$HOME/.config}/fzf/bin"
  fi
fi

if ! _omb_util_command_exists fzf; then
  _omb_util_print '[oh-my-bash] fzf not found, please install it from https://github.com/junegunn/fzf' >&2
  return
fi

# -- Activate -----------------------------------------------------------------
# fzf >= 0.46 ships `fzf --bash` which emits key bindings + completions in one go.
# Older git installs ship separate shell scripts under ~/.fzf/shell/.
if fzf --bash &>/dev/null; then
  eval "$(fzf --bash)"
else
  # Fallback for fzf < 0.46 git installs
  local _omb_plugin_fzf_base
  _omb_plugin_fzf_base=$(command -v fzf 2>/dev/null)
  # Ensure we got a real filesystem path, not a function/alias name
  if [[ -x $_omb_plugin_fzf_base ]]; then
    _omb_plugin_fzf_base=${_omb_plugin_fzf_base%/bin/fzf}
    [[ -s $_omb_plugin_fzf_base/shell/key-bindings.bash ]] &&
      source "$_omb_plugin_fzf_base/shell/key-bindings.bash"
    [[ $- == *i* && -s $_omb_plugin_fzf_base/shell/completion.bash ]] &&
      source "$_omb_plugin_fzf_base/shell/completion.bash"
  fi
  unset -v _omb_plugin_fzf_base
fi
