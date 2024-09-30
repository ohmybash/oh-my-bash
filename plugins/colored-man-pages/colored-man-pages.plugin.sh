#! bash oh-my-bash.module

# Safety get the colors.
if tput setaf 1 &> /dev/null; then
  COLORED_MAN_PAGES_BLACK=$(tput setaf 0)
  COLORED_MAN_PAGES_RED=$(tput setaf 1)
  COLORED_MAN_PAGES_GREEN=$(tput setaf 2)
  COLORED_MAN_PAGES_YELLOW=$(tput setaf 3)
  COLORED_MAN_PAGES_BLUE=$(tput setaf 4)
  COLORED_MAN_PAGES_MAGENTA=$(tput setaf 5)
  COLORED_MAN_PAGES_CYAN=$(tput setaf 6)
  COLORED_MAN_PAGES_WHITE=$(tput setaf 7)
  COLORED_MAN_PAGES_BOLD=$(tput bold)
  COLORED_MAN_PAGES_RESET=$(tput sgr0)

  # Extra Styles
  export LESS_TERMCAP_mr=$(tput rev) # Reverse
  export LESS_TERMCAP_mh=$(tput dim) # Half Bright
  export LESS_TERMCAP_ZN=$(tput ssubm) # Subscript
  export LESS_TERMCAP_ZV=$(tput rsubm) # Reverse Superscript
  export LESS_TERMCAP_ZO=$(tput ssupm) # Subscript
  export LESS_TERMCAP_ZW=$(tput rsupm) # Reverse Superscript
else
  COLORED_MAN_PAGES_BLACK="\033[1;30m"
  COLORED_MAN_PAGES_RED="\033[1;31m"
  COLORED_MAN_PAGES_GREEN="\033[1;32m"
  COLORED_MAN_PAGES_YELLOW="\033[1;33m"
  COLORED_MAN_PAGES_BLUE="\033[1;34m"
  COLORED_MAN_PAGES_MAGENTA="\033[1;35m"
  COLORED_MAN_PAGES_CYAN="\033[1;36m"
  COLORED_MAN_PAGES_WHITE="\033[1;37m"
  COLORED_MAN_PAGES_BOLD=""
  COLORED_MAN_PAGES_RESET="\033[m"
fi

# Bold and Blinking
export LESS_TERMCAP_mb=$COLORED_MAN_PAGES_GREEN
export LESS_TERMCAP_md=$COLORED_MAN_PAGES_BOLD$COLORED_MAN_PAGES_GREEN
export LESS_TERMCAP_me=$COLORED_MAN_PAGES_RESET

# Standout Mode
export LESS_TERMCAP_so=$COLORED_MAN_PAGES_YELLOW
export LESS_TERMCAP_se=$COLORED_MAN_PAGES_RESET

# Underline
export LESS_TERMCAP_us=$COLORED_MAN_PAGES_MAGENTA
export LESS_TERMCAP_ue=$COLORED_MAN_PAGES_RESET
