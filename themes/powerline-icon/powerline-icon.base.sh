#! bash oh-my-bash.module

source "$OSH/themes/powerline/powerline.base.sh"

function __powerline_user_info_prompt {
  local user_info=""
  local color=${USER_INFO_THEME_PROMPT_COLOR}
  local secondary_color="${USER_INFO_THEME_PROMPT_SECONDARY_COLOR}"

  if [[ "${THEME_CHECK_SUDO}" = true ]]; then
    # check whether sudo is active for no-password executions
    if sudo -n cat <<< c3bcc5c 2>&1 | grep -q c3bcc5c; then
      color=${USER_INFO_THEME_PROMPT_COLOR_SUDO}
    fi
  fi
  case "${POWERLINE_PROMPT_USER_INFO_MODE}" in
    "sudo")
      if [[ "${color}" == "${USER_INFO_THEME_PROMPT_COLOR_SUDO}" ]]; then
        user_info="!"
      fi
      ;;
    *)
      if [[ -n "${SSH_CLIENT}" ]]; then
        user_info="${USER_INFO_SSH_CHAR}${USER}@${HOSTNAME}"
      else
        user_info="${USER}"
      fi
      ;;
  esac
  [[ -n "${user_info}" ]] && echo "🐧 ${user_info} `date +%X\ %D`|${color}|${secondary_color}"
}

function __powerline_cwd_prompt {
  echo "$(pwd | sed "s|^${HOME}|🏠|")|${CWD_THEME_PROMPT_COLOR}"
}

function __powerline_last_status_prompt {
  if [[ "$1" -ne 0 ]]; then
    echo "❌${1}|${LAST_STATUS_THEME_PROMPT_COLOR}"
  else
    echo "✅|${LAST_STATUS_THEME_PROMPT_COLOR_SUCCESS}"
  fi
}

function __powerline_prompt_command {
  local last_status="$?" ## always the first
  local separator_char="${POWERLINE_PROMPT_CHAR}"

  LEFT_PROMPT=""
  SEGMENTS_AT_LEFT=0
  LAST_SEGMENT_COLOR=""

  # The IFS (internal field seperator) may have been changed outside to not contain
  # the space character ' ' whence we need to make sure that the space separated list
  # stored in POWERLINE_PROMPT is converted into an array correctly.
  IFS=' ' read -r -a POWERLINE_PROMPT_ARRAY <<< "${POWERLINE_PROMPT}"

  ## left prompt ##
  for segment in ${POWERLINE_PROMPT_ARRAY[@]}; do
    local info="$(__powerline_${segment}_prompt)"
    [[ -n "${info}" ]] && __powerline_left_segment "${info}"
  done
  __powerline_left_segment $(__powerline_last_status_prompt ${last_status})
  [[ -n "${LEFT_PROMPT}" ]] && LEFT_PROMPT+="$(set_color ${LAST_SEGMENT_COLOR} -)${separator_char}${_omb_prompt_normal}"

  PS1="${LEFT_PROMPT} "

  ## cleanup ##
  unset LAST_SEGMENT_COLOR \
        LEFT_PROMPT \
        SEGMENTS_AT_LEFT
}
