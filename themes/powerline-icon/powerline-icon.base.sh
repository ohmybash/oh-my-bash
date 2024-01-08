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
