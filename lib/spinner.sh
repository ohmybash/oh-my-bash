#! bash oh-my-bash.module
#
# Move a process to background and track its progress in a smoothier way.
# Could be use if $TERM not set.
#
# Examples
#
# echo -ne "${_omb_term_brown}I am running..."
# ( my_long_task_running ) &
# spinner
# echo -ne "...${_omb_term_reset} ${_omb_term_green}DONE${_omb_term_reset}"
#

# This spinner is used when there is a terminal.
function term_spinner {
  local pid=$!
  local delay=0.1
  local spinstr='|/-\'
  while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
    local temp=${spinstr#?}
    printf " [%c]  " "$spinstr"
    local spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    printf "\b\b\b\b\b\b"
  done
  printf "    \b\b\b\b"
}

function no_term_spinner {
  local pid=$!
  local delay=0.1
  local spinstr='|/-\'
  while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
    printf "."
    sleep 2
  done
  echo " ✓ "
}

function spinner {
  if [[ -z "$TERM" ]]; then
    no_term_spinner
  else
    term_spinner
  fi
}
