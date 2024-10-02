#! bash oh-my-bash.module
#
# Colored Man Pages Plugin
#
# This plugin is based on the following Oh-My-Zsh plugin:
# https://github.com/ohmyzsh/ohmyzsh/blob/6bc4c80c7db072a0d2d265eb3589bbe52e0d2737/plugins/colored-man-pages/colored-man-pages.plugin.zsh

# Adds the LESS_TERMCAP_* variables to color the man pages.
function colored {
  local -x LESS_TERMCAP_mb=$_omb_term_red
  local -x LESS_TERMCAP_md=$_omb_term_bold_red
  local -x LESS_TERMCAP_me=$_omb_term_reset
  local -x LESS_TERMCAP_so=$_omb_term_bold_yellow
  local -x LESS_TERMCAP_se=$_omb_term_reset
  local -x LESS_TERMCAP_us=$_omb_term_green
  local -x LESS_TERMCAP_ue=$_omb_term_reset

  # Prefer `less` whenever available, since we specifically configured
  # environment for it.
  local -x PAGER=$(type -P less || _omb_util_print "$PAGER")
  local -x GROFF_NO_SGR=1

  command "$@"
}

# Wrapper for man to colorize the output.
_omb_util_binary_exists man &&
  function man {
    colored "$FUNCNAME" "$@"
  }

# Wrapper for dman to colorize the output.
_omb_util_binary_exists dman &&
  function dman {
    colored "$FUNCNAME" "$@"
  }

# Wrapper for debman to colorize the output.
_omb_util_binary_exists debman &&
  function debman {
    colored "$FUNCNAME" "$@"
  }
