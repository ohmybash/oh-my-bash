#! bash oh-my-bash.module

source "$OSH/themes/powerline/powerline.base.sh"

: "${OMB_THEME_POWERLINE_ICON_USER=🐧}"
: "${OMB_THEME_POWERLINE_ICON_HOME=🏠}"
: "${OMB_THEME_POWERLINE_ICON_EXIT_FAILURE=❌}"
: "${OMB_THEME_POWERLINE_ICON_EXIT_SUCCESS=✅}"

function __powerline_user_info_prompt {
  local user_info=""
  local color=$USER_INFO_THEME_PROMPT_COLOR
  local secondary_color=$USER_INFO_THEME_PROMPT_SECONDARY_COLOR

  if [[ $THEME_CHECK_SUDO == true ]]; then
    # check whether sudo is active for no-password executions
    if sudo -n cat <<< c3bcc5c 2>&1 | grep -q c3bcc5c; then
      color=${USER_INFO_THEME_PROMPT_COLOR_SUDO}
    fi
  fi
  case $POWERLINE_PROMPT_USER_INFO_MODE in
  "sudo")
    if [[ $color == "$USER_INFO_THEME_PROMPT_COLOR_SUDO" ]]; then
      user_info="!"
    fi
    ;;
  *)
    if [[ $SSH_CLIENT ]]; then
      user_info=$USER_INFO_SSH_CHAR$USER@$HOSTNAME
    else
      user_info=$USER
    fi
    ;;
  esac
  if [[ $user_info ]]; then
    local clock=$(date +"${OMB_THEME_POWERLINE_ICON_CLOCK-%X %D}")
    _omb_util_print "$OMB_THEME_POWERLINE_ICON_USER $user_info${clock:+ $clock}|$color|$secondary_color"
  fi
}

function __powerline_cwd_prompt {
  _omb_util_print "$(pwd | sed "s|^$HOME|$OMB_THEME_POWERLINE_ICON_HOME|")|$CWD_THEME_PROMPT_COLOR"
}

function __powerline_last_status_prompt {
  if (($1 != 0)); then
    _omb_util_print "$OMB_THEME_POWERLINE_ICON_EXIT_FAILURE${1}|${LAST_STATUS_THEME_PROMPT_COLOR}"
  else
    _omb_util_print "$OMB_THEME_POWERLINE_ICON_EXIT_SUCCESS|${LAST_STATUS_THEME_PROMPT_COLOR_SUCCESS}"
  fi
}
