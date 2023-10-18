#! bash oh-my-bash.module
############################---Description---###################################
#                                                                              #
# Summary       : A collection of handy utilities and functions for bash       #
# Support       : destro.nnt@gmail.com                                         #
# Created date  : Mar 18,2017                                                  #
# Latest Modified date : Mar 18,2017                                           #
#                                                                              #
################################################################################

############################---Usage---#########################################

# source ~/path/to/directory/utils.sh

########################## Styled text output ##################################

# e_header "I am a sample script"
# e_success "I am a success message"
# e_error "I am an error message"
# e_warning "I am a warning message"
# e_underline "I am underlined text"
# e_bold "I am bold text"
# e_note "I am a note"

################# Performing simple Yes/No confirmations #######################

# seek_confirmation "Do you want to print a success message?"
# if is_confirmed; then
#   e_success "Here is a success message"
# else
#   e_error "You did not ask for a success message"
# fi

############ Testing if packages, apps, gems, etc. are installed ###############

# if _omb_util_command_exists 'git'; then
#   e_success "Git good to go"
# else
#   e_error "Git should be installed. It isn't. Aborting."
#   exit 1
# fi

# if is_os "darwin"; then
#   e_success "You are on a mac"
# else
#   e_error "You are not on a mac"
#   exit 1
# fi

##################### Sending notifications to Pushover ########################

# pushover "We just finished performing a lengthy task."

############################### Comparing A List ###############################

# recipes=(
#   A-random-package
#   bash
#   Another-random-package
#   git
# )
# list="$(to_install "${recipes[*]}" "$(brew list)")"
# if [[ "$list" ]]; then
# for item in ${list[@]}
#   do
#     echo "$item is not on the list"
#   done
# else
# e_arrow "Nothing to install.  You've already got them all."
# fi


################################################################################

function _omb_util_setexit {
  return "$1"
}

function _omb_util_defun_print {
  builtin eval -- "function $1 { local $3; $2 \"\$@\" && printf '%s\n' \"\${$3}\"; }"
}

#
# Test whether a command---either an alias, a keyword, a function, a builtin,
# or a file---is defined.
#
# $1 = cmd to test
#
# Usage:
#
#   if _omb_util_command_exists 'git'; then
#     some action
#   else
#     some other action
#   fi
#

if ((_omb_bash_version >= 40000)); then
  function _omb_util_command_exists {
    type -t -- "$@" &>/dev/null # bash-4.0
  }
  function _omb_util_binary_exists {
    type -P -- "$@" &>/dev/null # bash-4.0
  }
else
  function _omb_util_command_exists {
    while (($#)); do
      type -t -- "$1" &>/dev/null || return 1
      shift
    done
  }
  function _omb_util_binary_exists {
    while (($#)); do
      type -P -- "$1" &>/dev/null || return 1
      shift
    done
  }
fi
function _omb_util_function_exists {
  declare -F "$@" &>/dev/null # bash-3.2
}

#
# Set Colors
#
# Use colors, but only if connected to a terminal, and that terminal
# supports them.  These colors are intended to be used with `echo`
#
function _omb_term_color_initialize {
  local name
  local -a normal_colors=(black brown green olive navy purple teal silver)
  local -a bright_colors=(gray red lime yellow blue magenta cyan white)

  if [[ ! -t 1 ]]; then
    _omb_term_colors=
    _omb_term_bold=
    _omb_term_underline=
    _omb_term_reset=
    _omb_term_normal=
    _omb_term_reset_color=
    for name in "${normal_colors[@]}" "${bright_colors[@]}" violet; do
      printf -v "_omb_term_$name" ''
      printf -v "_omb_term_background_$name" ''
      printf -v "_omb_term_bold_$name" ''
      printf -v "_omb_term_underline_$name" ''
    done
    return 0
  fi

  if _omb_util_binary_exists tput; then
    _omb_term_colors=$(tput colors 2>/dev/null || tput Co 2>/dev/null)
    _omb_term_bold=$(tput bold 2>/dev/null || tput md 2>/dev/null)
    _omb_term_underline=$(tput smul 2>/dev/null || tput ul 2>/dev/null)
    _omb_term_reset=$(tput sgr0 2>/dev/null || tput me 2>/dev/null)
  else
    _omb_term_colors=
    _omb_term_bold=$'\e[1m'
    _omb_term_underline=$'\e[4m'
    _omb_term_reset=$'\e[0m'
  fi
  _omb_term_normal=$'\e[0m'
  _omb_term_reset_color=$'\e[39m'

  # normal colors
  if ((_omb_term_colors >= 8)); then
    local index
    for ((index = 0; index < 8; index++)); do
      local fg=$(tput setaf "$index" 2>/dev/null || tput AF "$index" 2>/dev/null)
      [[ $fg ]] || fg=$'\e[3'$index'm'
      printf -v "_omb_term_${normal_colors[index]}" %s "$fg"
      printf -v "_omb_term_background_${normal_colors[index]}" '\e[4%sm' "$index"
    done
  else
    local index
    for ((index = 0; index < 8; index++)); do
      printf -v "_omb_term_${normal_colors[index]}" '\e[3%sm' "$index"
      printf -v "_omb_term_background_${normal_colors[index]}" '\e[4%sm' "$index"
    done
  fi

  # bright colors
  if ((_omb_term_colors >= 16)); then
    local index
    for ((index = 0; index < 8; index++)); do
      local fg=$(tput setaf $((index+8)) 2>/dev/null || tput AF $((index+8)) 2>/dev/null)
      [[ $fg ]] || fg=$'\e[9'$index'm'
      local refbg=_omb_term_background_${normal_colors[index]}
      local bg=${!refbg}$'\e[10'$index'm'
      printf -v "_omb_term_${bright_colors[index]}" %s "$fg"
      printf -v "_omb_term_background_${bright_colors[index]}" %s "$bg"
    done
  else
    # copy normal colors to bright colors (with bold)
    local index
    for ((index = 0; index < 8; index++)); do
      local reffg=_omb_term_${normal_colors[index]}
      local refbg=_omb_term_background_${normal_colors[index]}
      printf -v "_omb_term_${bright_colors[index]}" %s "$_omb_term_bold${!reffg}"
      printf -v "_omb_term_background_${bright_colors[index]}" %s "$_omb_term_bold${!refbg}"
    done
  fi

  # index colors
  if ((_omb_term_colors == 256)); then
    _omb_term_violet=$'\e[38;5;171m'
    _omb_term_background_violet=$'\e[48;5;171m'
  else
    _omb_term_violet=$_omb_term_purple
    _omb_term_background_violet=$_omb_term_background_purple
  fi

  # bold / underline versions
  for name in "${normal_colors[@]}" "${bright_colors[@]}" violet; do
    local ref=_omb_term_$name
    printf -v "_omb_term_bold_$name" %s "$_omb_term_bold${!ref}"
    printf -v "_omb_term_underline_$name" %s "$_omb_term_underline${!ref}"
  done
}
_omb_term_color_initialize

#
# Headers and Logging
#
function _omb_log_header    { printf "\n${_omb_term_bold}${_omb_term_violet}==========  %s  ==========${_omb_term_reset}\n" "$@"; }
function _omb_log_arrow     { printf "➜ %s\n" "$@"; }
function _omb_log_success   { printf "${_omb_term_green}✔ %s${_omb_term_reset}\n" "$@"; }
function _omb_log_error     { printf "${_omb_term_brown}✖ %s${_omb_term_reset}\n" "$@"; }
function _omb_log_warning   { printf "${_omb_term_olive}➜ %s${_omb_term_reset}\n" "$@"; }
function _omb_log_underline { printf "${_omb_term_underline}${_omb_term_bold}%s${_omb_term_reset}\n" "$@"; }
function _omb_log_bold      { printf "${_omb_term_bold}%s${_omb_term_reset}\n" "$@"; }
function _omb_log_note      { printf "${_omb_term_underline}${_omb_term_bold}${_omb_term_navy}Note:${_omb_term_reset}  ${_omb_term_olive}%s${_omb_term_reset}\n" "$@"; }

#
# USAGE FOR SEEKING CONFIRMATION
# seek_confirmation "Ask a question"
# Credit: https://github.com/kevva/dotfiles
#
# if is_confirmed; then
#   some action
# else
#   some other action
# fi
#
function seek_confirmation {
  printf "\\n${_omb_term_bold}%s${_omb_term_reset}" "$@"
  read -rp " (y/n) " -n 1
  printf "\\n"
}

# Test whether the result of an 'ask' is a confirmation
function is_confirmed {
  [[ $REPLY =~ ^[Yy]$ ]]
}

#
# Test which OS the user runs
# $1 = OS to test
# Usage: if is_os 'darwin'; then
#
function is_os {
  [[ $OSTYPE == $1* ]]
}

#
# Pushover Notifications
# Usage: pushover "Title Goes Here" "Message Goes Here"
# Credit: http://ryonsherman.blogspot.com/2012/10/shell-script-to-send-pushover.html
#
function pushover {
  PUSHOVERURL="https://api.pushover.net/1/messages.json"
  API_KEY=$PUSHOVER_API_KEY
  USER_KEY=$PUSHOVER_USER_KEY
  DEVICE=$PUSHOVER_DEVICE

  TITLE="${1}"
  MESSAGE="${2}"

  curl \
  -F "token=${API_KEY}" \
  -F "user=${USER_KEY}" \
  -F "device=${DEVICE}" \
  -F "title=${TITLE}" \
  -F "message=${MESSAGE}" \
  "${PUSHOVERURL}" > /dev/null 2>&1
}

## @fn _omb_util_get_shopt optnames...
##   @var[out] __shopt
if ((_omb_bash_version >= 40100)); then
  function _omb_util_get_shopt { __shopt=$BASHOPTS; }
else
  function _omb_util_get_shopt {
    __shopt=
    local opt
    for opt; do
      if shopt -q "$opt" &>/dev/null; then
        __shopt=${__shopt:+$__shopt:}$opt
      fi
    done
  }
fi

_omb_util_unload_hook=()
function _omb_util_unload {
  local hook
  for hook in "${_omb_util_unload_hook[@]}"; do
    eval -- "$hook"
  done
}

_omb_util_original_PS1=$PS1
# shellcheck disable=SC2016
_omb_util_unload_hook+=('PS1=$_omb_util_original_PS1')

_omb_util_prompt_command=()
function _omb_util_prompt_command_hook {
  local status=$? lastarg=$_ hook
  for hook in "${_omb_util_prompt_command[@]}"; do
    _omb_util_setexit "$status" "$lastarg"
    eval -- "$hook"
  done
  _omb_util_setexit "$status"
}

_omb_util_unload_hook+=('_omb_util_prompt_command=()')

: "${_omb_util_prompt_command_setup=}"
function _omb_util_add_prompt_command {
  local other
  for other in "${_omb_util_prompt_command[@]}"; do
    [[ $1 == "$other" ]] && return 0
  done
  _omb_util_prompt_command+=("$1")

  if [[ ! $_omb_util_prompt_command_setup ]]; then
    _omb_util_prompt_command_setup=1
    local hook=_omb_util_prompt_command_hook

    # See if we need to use the overriden version
    if _omb_util_function_exists append_prompt_command_override; then
      append_prompt_command_override "$hook"
      return
    fi

    # Set OS dependent exact match regular expression
    local prompt_re
    if [[ $OSTYPE == darwin* ]]; then
      # macOS
      prompt_re='[[:<:]]'$hook'[[:>:]]'
    else
      # Linux, FreeBSD, etc.
      prompt_re='\<'$hook'\>'
    fi
    [[ $PROMPT_COMMAND =~ $prompt_re ]] && return 0

    if ((_omb_bash_version >= 50100)); then
      local other
      for other in "${PROMPT_COMMAND[@]}"; do
        [[ $hook == "$other" ]] && return 0
      done
      PROMPT_COMMAND+=("$hook")
    else
      PROMPT_COMMAND="$hook${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
    fi
  fi
}

## @fn _omb_util_split array str [sep]
function _omb_util_split {
  local __set=$- IFS=${3:-$' \t\n'}
  set -f
  eval -- "$1=(\$2)"
  [[ $__set == *f* ]] || set +f
  return 0
}

function _omb_util_glob_expand {
  local __set=$- __shopt __gignore=$GLOBIGNORE
  _omb_util_get_shopt failglob nullglob extglob

  shopt -u failglob
  shopt -s nullglob
  shopt -s extglob
  set +f
  GLOBIGNORE=

  eval -- "$1=($2)"

  GLOBIGNORE=$__gignore
  # Note: dotglob is changed by GLOBIGNORE
  if [[ :$__shopt: == *:dotglob:* ]]; then
    shopt -s dotglob
  else
    shopt -u dotglob
  fi
  [[ $__set == *f* ]] && set -f
  [[ :$__shopt: != *:extglob:* ]] && shopt -u extglob
  [[ :$__shopt: != *:nullglob:* ]] && shopt -u nullglob
  [[ :$__shopt: == *:failglob:* ]] && shopt -s failglob
  return 0
}

function _omb_util_split {
  local __set=$- IFS=${3:-$' \t\n'}
  set -f
  eval -- "$1=(\$2)"
  [[ $__set == *f* ]] || set +f
  return 0
}

function _omb_util_alias {
  case ${OMB_DEFAULT_ALIASES:-enable} in
  (disable) return 0 ;;
  (check) alias -- "${1%%=*}" &>/dev/null && return 0 ;;
  (enable) ;;
  (*)
    _omb_log_error "invalid value: OMB_DEFAULT_ALIASES='${OMB_DEFAULT_ALIASES-}' (expect: enable|disable|check)" >&2
    return 2
  esac
  alias -- "$1"
}

function _omb_util_alias_delayed__init {
  local _omb_name=$1 _omb_init=${FUNCNAME[1]}
  local _omb_command=$_omb_name
  "_omb_util_alias_select_$_omb_name"

  if [[ ! $_omb_command || $_omb_command == "$_omb_name" ]]; then
    unalias "$_omb_name"
  else
    alias "$_omb_name=$_omb_command"
  fi || return 1

  eval -- "function $_omb_init { command ${_omb_command:-$_omb_name} \"\$@\"; }" && "$_omb_init" "${@:2}"
}
function _omb_util_alias_delayed {
  local name=$1 opts=${2-}
  local func=_omb_util_alias_init_$name
  eval -- "function $func { _omb_util_alias_delayed__init $name \"\$@\"; }"
  if [[ :$opts: == *:force:* ]]; then
    alias "$name=$func"
  else
    _omb_util_alias "$name=$func"
  fi
}

function _omb_util_mktemp {
  local template=tmp.oh-my-bash.XXXXXXXXXX
  if _omb_util_command_exists mktemp; then
    mktemp -t "$template"
  else
    m4 -D template="${TMPDIR:-/tmp}/$template" <<< 'mkstemp(template)'
  fi
}
