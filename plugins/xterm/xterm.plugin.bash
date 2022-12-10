#! bash oh-my-bash.module
# Description: automatically set your xterm title with host and location info'
# Source: https://github.com/Bash-it/bash-it/blob/bf2034d13d/plugins/available/xterm.plugin.bash
#
# @var[opt] PROMPT_CHAR ... This variable is shared with powerline
# @var[opt] OMB_PLUGIN_XTERM_SHORT_TERM_LINE
# @var[opt] OMB_PLUGIN_XTERM_SHORT_USER
# @var[opt] OMB_PLUGIN_XTERM_SHORT_HOSTNAME
#

_omb_module_require plugin:bash-preexec

function _omb_plugin_xterm_short_dirname {
  local dir_name=${PWD/~/\~}
  if [[ ${OMB_PLUGIN_XTERM_SHORT_TERM_LINE-} == true ]] && ((${#dir_name} > 8)); then
    dir_name=${dir_name##*/}
  fi
  echo "$dir_name"
}

function _omb_plugin_xterm_short_command {
  local input_command="$*"
  if [[ ${OMB_PLUGIN_XTERM_SHORT_TERM_LINE-} == true ]] && ((${#input_command} > 8)); then
    input_command=${input_command%% *}
  fi
  echo "$input_command"
}

function _omb_plugin_xterm_set_title {
  local title=${1:-terminal}
  printf '\e]0;%s\e\\' "$title"
}

function _omb_plugin_xterm_precmd_title {
  local user=${OMB_PLUGIN_XTERM_SHORT_USER:-$USER}
  local host=${OMB_PLUGIN_XTERM_SHORT_HOSTNAME:-$HOSTNAME}
  _omb_plugin_xterm_set_title "$user@$host $(_omb_plugin_xterm_short_dirname) ${PROMPT_CHAR:-\$}"
}

function _omb_plugin_xterm_preexec_title {
  local command_line=${BASH_COMMAND:-${1:-}}
  local directory_name=$(_omb_plugin_xterm_short_dirname)
  local short_command=$(_omb_plugin_xterm_short_command "$command_line")
  local user=${OMB_PLUGIN_XTERM_SHORT_USER:-$USER}
  local host=${OMB_PLUGIN_XTERM_SHORT_HOSTNAME:-$HOSTNAME}
  _omb_plugin_xterm_set_title "$short_command {$directory_name} ($user@$host)"
}

function set_xterm_title { _omb_plugin_xterm_set_title "$@"; }

precmd_functions+=(_omb_plugin_xterm_precmd_title)
preexec_functions+=(_omb_plugin_xterm_preexec_title)
