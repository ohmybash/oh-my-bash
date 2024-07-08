#! bash oh-my-bash.module

# Brainy Bash Prompt for Bash-it
# by MunifTanjim

#############
## Parsers ##
#############

function ____brainy_top_left_parse {
  local args
  _omb_util_split args "$1" '|'
  if [[ ${args[3]} ]]; then
    _TOP_LEFT+=${args[2]}${args[3]}
  fi
  _TOP_LEFT+=${args[0]}${args[1]}
  if [[ ${args[4]} ]]; then
    _TOP_LEFT+=${args[2]}${args[4]}
  fi
  _TOP_LEFT+=" "
}

function ____brainy_top_right_parse {
  local args
  _omb_util_split args "$1" '|'
  _TOP_RIGHT+=" "
  if [[ ${args[3]} ]]; then
    _TOP_RIGHT+=${args[2]}${args[3]}
  fi
  _TOP_RIGHT+=${args[0]}${args[1]}
  if [[ ${args[4]} ]]; then
    _TOP_RIGHT+=${args[2]}${args[4]}
  fi
  __TOP_RIGHT_LEN=$((__TOP_RIGHT_LEN + ${#args[1]} + ${#args[3]} + ${#args[4]} + 1))
  ((__SEG_AT_RIGHT += 1))
}

function ____brainy_bottom_parse {
  local args
  _omb_util_split args "$1" '|'
  _BOTTOM+=${args[0]}${args[1]}
  ((${#args[1]} > 0)) && _BOTTOM+=" "
}

function ____brainy_top {
  local _TOP_LEFT=""
  local _TOP_RIGHT=""
  local __TOP_RIGHT_LEN=0
  local __SEG_AT_RIGHT=0

  local seg info
  for seg in ${___BRAINY_TOP_LEFT}; do
    info=$(___brainy_prompt_"$seg")
    [[ $info ]] && ____brainy_top_left_parse "$info"
  done

  local ___cursor_right='\033[500C'
  _TOP_LEFT+=$___cursor_right

  for seg in ${___BRAINY_TOP_RIGHT}; do
    info=$(___brainy_prompt_"$seg")
    [[ $info ]] && ____brainy_top_right_parse "$info"
  done

  ((__TOP_RIGHT_LEN > 0)) && ((__TOP_RIGHT_LEN--))
  local ___cursor_adjust="\033[${__TOP_RIGHT_LEN}D"
  _TOP_LEFT+=$___cursor_adjust

  printf "%s%s" "$_TOP_LEFT" "$_TOP_RIGHT"
}

function ____brainy_bottom {
  local _BOTTOM="" seg
  for seg in $___BRAINY_BOTTOM; do
    local info=$(___brainy_prompt_"$seg")
    [[ $info ]] && ____brainy_bottom_parse "$info"
  done
  printf "\n%s" "$_BOTTOM"
}

##############
## Segments ##
##############

function ___brainy_prompt_user_info {
  local color=$_omb_prompt_bold_navy
  if [[ $THEME_SHOW_SUDO == true ]]; then
    if sudo -n id -u 2>&1 | grep -q 0; then
      color=$_omb_prompt_bold_brown
    fi
  fi
  local box="[|]"
  local info="\u@\H"
  if [[ $SSH_CLIENT ]]; then
    printf "%s|%s|%s|%s" "$color" "$info" "$_omb_prompt_bold_white" "$box"
  else
    printf "%s|%s" "$color" "$info"
  fi
}

function ___brainy_prompt_dir {
  local color=$_omb_prompt_bold_olive
  local box="[|]"
  local info="\w"
  printf "%s|%s|%s|%s" "$color" "$info" "$_omb_prompt_bold_white" "$box"
}

function ___brainy_prompt_scm {
  [[ $THEME_SHOW_SCM != true ]] && return
  local color=$_omb_prompt_bold_green
  local box="$(scm_char) "
  local info="$(scm_prompt_info)"
  printf "%s|%s|%s|%s" "$color" "$info" "$_omb_prompt_bold_white" "$box"
}

function ___brainy_prompt_python {
  [[ $THEME_SHOW_PYTHON != true ]] && return
  local color=$_omb_prompt_bold_olive
  local box="[|]"
  local python_env
  _omb_prompt_get_python_env || return 0
  printf "%s|%s|%s|%s" "$color" "${python_env}" "$_omb_prompt_bold_navy" "$box"
}

function ___brainy_prompt_ruby {
  [[ $THEME_SHOW_RUBY != true ]] && return
  local color=$_omb_prompt_bold_white
  local box="[|]"
  local info="rb-$(_omb_prompt_print_ruby_env)"
  printf "%s|%s|%s|%s" "$color" "$info" "$_omb_prompt_bold_brown" "$box"
}

function ___brainy_prompt_todo {
  [[ $THEME_SHOW_TODO != true ]] && return
  _omb_util_binary_exists todo.sh || return
  local color=$_omb_prompt_bold_white
  local box="[|]"
  local info="t:$(todo.sh ls | command grep -E "TODO: [0-9]+ of ([0-9]+)" | awk '{ print $4 }' )"
  printf "%s|%s|%s|%s" "$color" "$info" "$_omb_prompt_bold_green" "$box"
}

function ___brainy_prompt_clock {
  [[ $THEME_SHOW_CLOCK != true ]] && return
  local color=$THEME_CLOCK_COLOR
  local box="[|]"
  local info="$(date +"${THEME_CLOCK_FORMAT}")"
  printf "%s|%s|%s|%s" "$color" "$info" "$_omb_prompt_bold_purple" "$box"
}

function ___brainy_prompt_battery {
  [[ -e $OSH/plugins/battery/battery.plugin.sh ]] || return 0
  [[ $THEME_SHOW_BATTERY != true ]] && return
  local info=$(battery_percentage)
  local color=$_omb_prompt_bold_green
  if ((info < 50)); then
    color=$_omb_prompt_bold_olive
  elif ((info < 25)); then
    color=$_omb_prompt_bold_brown
  fi
  local box="[|]"
  ac_adapter_connected && info+="+"
  [[ $info == 100+ ]] && info="AC"
  printf "%s|%s|%s|%s" "$color" "$info" "$_omb_prompt_bold_white" "$box"
}

function ___brainy_prompt_exitcode {
  [[ $THEME_SHOW_EXITCODE != true ]] && return
  local color=$_omb_prompt_bold_purple
  ((exitcode != 0)) && printf "%s|%s" "$color" "$exitcode"
}

function ___brainy_prompt_char {
  local color=$_omb_prompt_bold_white
  local prompt_char="${__BRAINY_PROMPT_CHAR_PS1}"
  printf "%s|%s" "$color" "${prompt_char}"
}

#########
## cli ##
#########

function __brainy_show {
  local _seg=${1:-}
  export "THEME_SHOW_${_seg}=true"
}

function __brainy_hide {
  local _seg=${1:-}
  export "THEME_SHOW_${_seg}=false"
}

function _brainy_completion {
  COMPREPLY=()
  local cur=${COMP_WORDS[COMP_CWORD]}
  local _action=${COMP_WORDS[1]}
  local actions="show hide"
  local segments="battery clock exitcode python ruby scm sudo todo"
  case "$_action" in
    show)
      COMPREPLY=( $(compgen -W "$segments" -- "$cur") )
      return 0
      ;;
    hide)
      COMPREPLY=( $(compgen -W "$segments" -- "$cur") )
      return 0
      ;;
  esac

  COMPREPLY=( $(compgen -W "$actions" -- "$cur") )
  return 0
}

function brainy {
  local action=${1:-}
  shift
  local segs IFS=$' \t\n'
  _omb_util_split segs "$*"
  local func
  case $action in
    show)
      func=__brainy_show;;
    hide)
      func=__brainy_hide;;
  esac
  local seg
  for seg in "${segs[@]}"; do
    seg=$(printf "%s" "${seg}" | tr '[:lower:]' '[:upper:]')
    "$func" "${seg}"
  done
}

complete -F _brainy_completion brainy

###############
## Variables ##
###############

export SCM_THEME_PROMPT_PREFIX=""
export SCM_THEME_PROMPT_SUFFIX=""

export RBENV_THEME_PROMPT_PREFIX=""
export RBENV_THEME_PROMPT_SUFFIX=""
export RBFU_THEME_PROMPT_PREFIX=""
export RBFU_THEME_PROMPT_SUFFIX=""
export RVM_THEME_PROMPT_PREFIX=""
export RVM_THEME_PROMPT_SUFFIX=""

export SCM_THEME_PROMPT_DIRTY=" ${_omb_prompt_bold_brown}✗${_omb_prompt_normal}"
export SCM_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓${_omb_prompt_normal}"

THEME_SHOW_SUDO=${THEME_SHOW_SUDO:-"true"}
THEME_SHOW_SCM=${THEME_SHOW_SCM:-"true"}
THEME_SHOW_RUBY=${THEME_SHOW_RUBY:-"false"}
THEME_SHOW_PYTHON=${THEME_SHOW_PYTHON:-"false"}
THEME_SHOW_CLOCK=${THEME_SHOW_CLOCK:-"true"}
THEME_SHOW_TODO=${THEME_SHOW_TODO:-"false"}
THEME_SHOW_BATTERY=${THEME_SHOW_BATTERY:-"false"}
THEME_SHOW_EXITCODE=${THEME_SHOW_EXITCODE:-"true"}

THEME_CLOCK_COLOR=${THEME_CLOCK_COLOR:-"$_omb_prompt_bold_white"}
THEME_CLOCK_FORMAT=${THEME_CLOCK_FORMAT:-"%H:%M:%S"}

__BRAINY_PROMPT_CHAR_PS1=${THEME_PROMPT_CHAR_PS1:-">"}
__BRAINY_PROMPT_CHAR_PS2=${THEME_PROMPT_CHAR_PS2:-"\\"}

___BRAINY_TOP_LEFT=${___BRAINY_TOP_LEFT:-"user_info dir scm"}
___BRAINY_TOP_RIGHT=${___BRAINY_TOP_RIGHT:-"python ruby todo clock battery"}
___BRAINY_BOTTOM=${___BRAINY_BOTTOM:-"exitcode char"}

############
## Prompt ##
############

function __brainy_ps1 {
  printf "%s%s%s" "$(____brainy_top)" "$(____brainy_bottom)" "$_omb_prompt_normal"
}

function __brainy_ps2 {
  local color=$_omb_prompt_bold_white
  printf "%s%s%s" "$color" "${__BRAINY_PROMPT_CHAR_PS2}  " "$_omb_prompt_normal"
}

function _omb_theme_PROMPT_COMMAND {
  local exitcode=$? # used by segment "exitcode"
  PS1=$(__brainy_ps1)
  PS2=$(__brainy_ps2)
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
