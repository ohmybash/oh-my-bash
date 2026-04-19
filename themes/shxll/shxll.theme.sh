#! bash oh-my-bash.module

OSH_THEME_GIT_PROMPT_DIRTY="*"
OSH_THEME_GIT_PROMPT_CLEAN=""

__omb_theme_cmd_started=0
__omb_theme_cmd_start=0
__omb_theme_cmd_armed=1
__omb_theme_prev_debug_trap=""

__omb_theme_prev_debug_trap_src="$(trap -p DEBUG)"
if [[ $__omb_theme_prev_debug_trap_src =~ ^trap\ --\ \'(.*)\'\ DEBUG$ ]]; then
  __omb_theme_prev_debug_trap="${BASH_REMATCH[1]}"
fi
unset __omb_theme_prev_debug_trap_src

_omb_theme_now() {
  if [[ -n ${EPOCHREALTIME-} ]]; then
    local sec frac
    sec=${EPOCHREALTIME%%[.,]*}
    frac=${EPOCHREALTIME#*[.,]}
    frac=${frac:0:3}
    printf '%s%03d' "$sec" "$((10#${frac:-0}))"
  else
    date +%s%3N
  fi
}

_omb_theme_debug_trap() {
  local func
  for func in "${FUNCNAME[@]}"; do
    if [[ $func == _omb_theme_PROMPT_COMMAND ]]; then
      return
    fi
  done

  if [[ $__omb_theme_cmd_armed -eq 1 && $__omb_theme_cmd_started -eq 0 ]]; then
    __omb_theme_cmd_start=$(_omb_theme_now)
    __omb_theme_cmd_started=1
    __omb_theme_cmd_armed=0
  fi

  if [[ -n $__omb_theme_prev_debug_trap ]]; then
    eval -- "$__omb_theme_prev_debug_trap"
  fi
}

trap '_omb_theme_debug_trap' DEBUG

function _omb_theme_shxll_way_prompt_scm {
  local CHAR branch dirty color
  CHAR=$(scm_char)

  if [[ $CHAR != "$SCM_NONE_CHAR" ]]; then
    branch=$(git_current_branch)
    dirty=$(parse_git_dirty)

    if [[ -n "$dirty" ]]; then
      color="${_omb_prompt_yellow}"
    else
      color="${_omb_prompt_blue}"
    fi

    printf '%s' " ϟ ${color}${branch}${dirty}${_omb_prompt_normal}"
  fi
}

function _omb_theme_PROMPT_COMMAND {
  local exit_code=$?
  local time_str=""
  local scm_segment=""
  local python_venv=""
  local ps_username=""
  local ps_path=""
  local ps_user_mark=""
  local status=""

  if [[ $__omb_theme_cmd_started -eq 1 ]]; then
    local now elapsed_ms
    now=$(_omb_theme_now)
    elapsed_ms=$((now - __omb_theme_cmd_start))

    if ((elapsed_ms > 500)); then
      time_str="${_omb_prompt_gray}${elapsed_ms}ms${_omb_prompt_normal} "
    fi
  fi

  __omb_theme_cmd_started=0

  _omb_prompt_get_python_venv
  scm_segment=$(_omb_theme_shxll_way_prompt_scm)

  ps_username="${_omb_prompt_purple}\u${_omb_prompt_normal}"
  ps_path="${_omb_prompt_green}\w${_omb_prompt_normal}"
  ps_user_mark="${_omb_prompt_red}ホ${_omb_prompt_normal}"

  if [[ $exit_code -ne 0 ]]; then
    status="${_omb_prompt_red}(${exit_code})${_omb_prompt_normal} "
  fi

  PS1="$ps_username:$python_venv$ps_path$scm_segment $time_str$status$ps_user_mark "

  __omb_theme_cmd_armed=1
}

OMB_PROMPT_SHOW_PYTHON_VENV=${OMB_PROMPT_SHOW_PYTHON_VENV:-false}
OMB_PROMPT_VIRTUALENV_FORMAT="${_omb_prompt_olive}(%s)${_omb_prompt_reset_color} "

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
