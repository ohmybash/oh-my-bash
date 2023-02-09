#! bash oh-my-bash.module

# Initialize fasd, without setting up the prompt hook, which
# we want to be handled by oh-my-bash.

function _omb_plugin_fasd_prompt_func {
  local sink=${OMB_PLUGIN_FASD_SINK:-/dev/null}
  [[ $sink == /dev/null ]] && return 0
  fasd --proc "$(fasd --sanitize "$(history 1 | command sed 's/^[ ]*[0-9]*[ ]*//')")" >> "$sink" 2>&1
}

function _omb_plugin_fasd_initialize {
  if _omb_util_command_exists fasd; then
    eval -- "$(fasd --init posix-alias bash-ccomp bash-ccomp-install)"
    _omb_util_add_prompt_command _omb_plugin_fasd_prompt_func
  else
    echo 'fasd not found, plugin not activated.' >&2
  fi
}

_omb_plugin_fasd_initialize
