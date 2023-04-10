#! bash oh-my-bash.module

function _omb_plugin_sudo__is_inserted {
  [[ "$READLINE_LINE" = 'sudo '* ]]
}

function _omb_plugin_sudo_add_sudo {
  if [[ -z $READLINE_LINE ]]; then
    READLINE_LINE="$(fc -ln -1 | command sed 's/^[[:space:]]\{1,\}//')"
    READLINE_POINT=${#READLINE_LINE}
    _omb_plugin_sudo__is_inserted && return
  fi
  if _omb_plugin_sudo__is_inserted; then
    READLINE_LINE="${READLINE_LINE#sudo }"
    ((READLINE_POINT -= 5))
  else
    READLINE_LINE="sudo $READLINE_LINE"
    ((READLINE_POINT += 5))
  fi
  ((READLINE_POINT < 0)) && READLINE_POINT=0
}

bind -m emacs -x '"\e\e": _omb_plugin_sudo_add_sudo'
bind -m vi-insert -x '"\e\e": _omb_plugin_sudo_add_sudo'
bind -m vi-command -x '"\e\e": _omb_plugin_sudo_add_sudo'
