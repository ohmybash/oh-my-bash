#!/usr/bin/env sh

# Initialize fasd, without setting up the prompt hook, which
# we want to be handled by oh-my-bash.

_fasd_prompt_func() {
  [ -z "$_FASD_SINK" ] && _FASD_SINK=/dev/null
  eval "fasd --proc \$(fasd --sanitize \$(history 1 | \\
    sed "s/^[ ]*[0-9]*[ ]*//"))" >> "$_FASD_SINK" 2>&1
}

function _install_fasd() {
  type fasd >/dev/null 2>&1
  if [ "$?" == "0" ]; then
    eval "$(fasd --init posix-alias bash-ccomp bash-ccomp-install)"
    safe_append_prompt_command _fasd_prompt_func
  else
    echo "fasd not found, plugin not activated."
  fi
}


_install_fasd
