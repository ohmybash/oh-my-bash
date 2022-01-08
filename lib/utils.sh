#!/usr/bin/env bash
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

_omb_version=10000
_omb_bash_version=$((BASH_VERSINFO[0] * 10000 + BASH_VERSINFO[1] * 100 + BASH_VERSINFO[2]))

function _omb_util_defun_print {
  builtin eval -- "function $1 { local $3; $2 \"\$@\" && printf '%s\n' \"\${$3}\"; }"
}

function __omb_util_defun_deprecate__message {
  local old=$1 new=$2
  local v=__omb_util_DeprecateFunction_$old; v=${v//[!a-zA-Z0-9_]/'_'}
  [[ ${!v+set} ]] && return 0
  printf 'warning (oh-my-bash): %s\n' "\`$old' is deprecated. Use \`$new'." >&2
  printf -v "$v" done
}

function _omb_util_defun_deprecate {
  local warning=
  ((_omb_version>=$1)) &&
    warning='__omb_util_defun_deprecate__message "$2" "$3"; '
  builtin eval -- "function $2 { $warning$3 \"\$@\"; }"
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
  _omb_util_command_exists() {
    type -t -- "$@" &>/dev/null # bash-4.0
  }
  _omb_util_binary_exists() {
    type -P -- "$@" &>/dev/null # bash-4.0
  }
else
  _omb_util_command_exists() {
    while (($#)); do
      type -t -- "$1" &>/dev/null || return 1
      shift
    done
  }
  _omb_util_binary_exists() {
    while (($#)); do
      type -P -- "$1" &>/dev/null || return 1
      shift
    done
  }
fi
_omb_util_function_exists() {
  declare -F "$@" &>/dev/null # bash-3.2
}


#
# Set Colors
#
# Use colors, but only if connected to a terminal, and that terminal
# supports them.
if which tput >/dev/null 2>&1; then
    ncolors=$(tput colors)
fi
if [[ -t 1 && $ncolors && ncolors -ge 8 ]]; then
  bold=$(tput bold 2>/dev/null || tput md 2>/dev/null)
  underline=$(tput smul 2>/dev/null || tput ul 2>/dev/null)
  reset=$(tput sgr0 2>/dev/null || tput me 2>/dev/null)
  red=$(tput setaf 1 2>/dev/null || tput AF 1 2>/dev/null)
  green=$(tput setaf 2 2>/dev/null || tput AF 2 2>/dev/null)
  yellow=$(tput setaf 3 2>/dev/null || tput AF 3 2>/dev/null)
  blue=$(tput setaf 4 2>/dev/null || tput AF 4 2>/dev/null)
  purple=$(tput setaf 171 2>/dev/null || tput AF 171 2>/dev/null)
  tan=$(tput setaf 3 2>/dev/null || tput AF 3 2>/dev/null)
else
  bold=""
  underline=""
  reset=""
  red=""
  green=""
  yellow=""
  blue=""
  purple=""
  tan=""
fi

#
# Headers and Logging
#
_omb_log_header()    { printf "\n${bold}${purple}==========  %s  ==========${reset}\n" "$@"; }
_omb_log_arrow()     { printf "➜ %s\n" "$@"; }
_omb_log_success()   { printf "${green}✔ %s${reset}\n" "$@"; }
_omb_log_error()     { printf "${red}✖ %s${reset}\n" "$@"; }
_omb_log_warning()   { printf "${tan}➜ %s${reset}\n" "$@"; }
_omb_log_underline() { printf "${underline}${bold}%s${reset}\n" "$@"; }
_omb_log_bold()      { printf "${bold}%s${reset}\n" "$@"; }
_omb_log_note()      { printf "${underline}${bold}${blue}Note:${reset}  ${yellow}%s${reset}\n" "$@"; }

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
seek_confirmation() {
  printf "\\n${bold}%s${reset}" "$@"
  read -p " (y/n) " -n 1
  printf "\\n"
}

# Test whether the result of an 'ask' is a confirmation
is_confirmed() {
  [[ $REPLY =~ ^[Yy]$ ]]
}

#
# Test which OS the user runs
# $1 = OS to test
# Usage: if is_os 'darwin'; then
#
is_os() {
  [[ $OSTYPE == $1* ]]
}

#
# Pushover Notifications
# Usage: pushover "Title Goes Here" "Message Goes Here"
# Credit: http://ryonsherman.blogspot.com/2012/10/shell-script-to-send-pushover.html
#
pushover () {
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

_omb_util_add_prompt_command() {
  # Set OS dependent exact match regular expression
  local prompt_re
  if [[ $OSTYPE == darwin* ]]; then
    # macOS
    prompt_re='[[:<:]]'$1'[[:>:]]'
  else
    # Linux, FreeBSD, etc.
    prompt_re='\<'$1'\>'
  fi

  # See if we need to use the overriden version
  if _omb_util_function_exists append_prompt_command_override; then
    append_prompt_command_override "$1"
    return
  fi

  if [[ $PROMPT_COMMAND =~ $prompt_re ]]; then
    return
  else
    PROMPT_COMMAND="$1${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
  fi
}

_omb_util_glob_expand() {
  local set=$- shopt=$BASHOPTS gignore=$GLOBIGNORE

  shopt -u failglob
  shopt -s nullglob
  shopt -s extglob
  set +f
  GLOBIGNORE=

  eval -- "$1=($2)"

  GLOBIGNORE=$gignore
  # Note: dotglob is changed by GLOBIGNORE
  if [[ :$shopt: == *:dotglob:* ]]; then
    shopt -s dotglob
  else
    shopt -u dotglob
  fi
  [[ $set == *f* ]] && set -f
  [[ :$shopt: != *:extglob:* ]] && shopt -u extglob
  [[ :$shopt: != *:nullglob:* ]] && shopt -u nullglob
  [[ :$shopt: == *:failglob:* ]] && shopt -s failglob
  return 0
}
