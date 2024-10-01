#! bash oh-my-bash.module

# Bold and Blinking
export LESS_TERMCAP_mb=$_omb_term_green
export LESS_TERMCAP_md=$_omb_term_bold$_omb_term_green
export LESS_TERMCAP_me=$_omb_term_reset

# Standout Mode
export LESS_TERMCAP_so=$_omb_term_olive
export LESS_TERMCAP_se=$_omb_term_reset

# Underline
export LESS_TERMCAP_us=$_omb_term_purple
export LESS_TERMCAP_ue=$_omb_term_reset

# Extra Styles
if _omb_util_binary_exists tput; then
  export LESS_TERMCAP_mr=$(tput rev 2>/dev/null || tput mr 2>/dev/null)
  export LESS_TERMCAP_mh=$(tput dim 2>/dev/null || tput mh 2>/dev/null)
  export LESS_TERMCAP_ZN=$(tput ssubm 2>/dev/null)
  export LESS_TERMCAP_ZV=$(tput rsubm 2>/dev/null)
  export LESS_TERMCAP_ZO=$(tput ssupm 2>/dev/null)
  export LESS_TERMCAP_ZW=$(tput rsupm 2>/dev/null)
fi
