#! bash oh-my-bash.module

function _omb_plugin_sudo_add_sudo {
  function __omb_plugin_sudo_is_inserted {
    [[ "${READLINE_LINE::4}" = "sudo" ]]; return $?
  }
  if [[ -z $READLINE_LINE ]]; then
    READLINE_LINE="$(fc -ln -1 | command sed 's/^[[:space:]]\{1,\}//')"
    ((READLINE_POINT += ${#READLINE_LINE}))
    __omb_plugin_sudo_is_inserted && return
  fi
  if __omb_plugin_sudo_is_inserted; then
    READLINE_LINE="${READLINE_LINE//sudo /}"
    ((READLINE_POINT -= 5))
  else
    READLINE_LINE="sudo $READLINE_LINE"
    ((READLINE_POINT += 5))
  fi
}

bind -m emacs -x '"\e\e": _omb_plugin_sudo_add_sudo'
bind -m vi-insert -x '"\e\e": _omb_plugin_sudo_add_sudo'
bind -m vi-command -x '"\e\e": _omb_plugin_sudo_add_sudo'
