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

# if type_exists 'git'; then
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

#
# Set Colors
#
# Use colors, but only if connected to a terminal, and that terminal
# supports them.
if which tput >/dev/null 2>&1; then
    ncolors=$(tput colors)
fi
if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
  bold="$(tput bold)"
  underline=$(tput sgr 0 1)
  reset="$(tput sgr0)"
  red="$(tput setaf 1)"
  green="$(tput setaf 2)"
  yellow="$(tput setaf 3)"
  blue="$(tput setaf 4)"
  purple=$(tput setaf 171)
  tan=$(tput setaf 3)
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
e_header() { printf "\n${bold}${purple}==========  %s  ==========${reset}\n" "$@"
}
e_arrow() { printf "➜ %s\n" "$@"
}
e_success() { printf "${green}✔ %s${reset}\n" "$@"
}
e_error() { printf "${red}✖ %s${reset}\n" "$@"
}
e_warning() { printf "${tan}➜ %s${reset}\n" "$@"
}
e_underline() { printf "${underline}${bold}%s${reset}\n" "$@"
}
e_bold() { printf "${bold}%s${reset}\n" "$@"
}
e_note() { printf "${underline}${bold}${blue}Note:${reset}  ${yellow}%s${reset}\n" "$@"
}

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
  if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    return 0
  fi
  return 1
}

#
# Test whether a command exists
# $1 = cmd to test
# Usage:
# if type_exists 'git'; then
#   some action
# else
#   some other action
# fi
#
type_exists() {
  [ "$(type -P "$1")" ]
}

#
# Test which OS the user runs
# $1 = OS to test
# Usage: if is_os 'darwin'; then
#
is_os() {
  if [[ "${OSTYPE}" == $1* ]]; then
    return 0
  fi
  return 1
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
