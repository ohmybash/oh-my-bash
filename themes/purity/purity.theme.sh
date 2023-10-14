#! bash oh-my-bash.module

SCM_THEME_PROMPT_DIRTY=" ${_omb_prompt_bold_brown}⊘${_omb_prompt_normal}"
SCM_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓${_omb_prompt_normal}"
SCM_THEME_PROMPT_PREFIX="${_omb_prompt_reset_color}( "
SCM_THEME_PROMPT_SUFFIX=" ${_omb_prompt_reset_color})"

GIT_THEME_PROMPT_DIRTY=" ${_omb_prompt_bold_brown}⊘${_omb_prompt_normal}"
GIT_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓${_omb_prompt_normal}"
GIT_THEME_PROMPT_PREFIX="${_omb_prompt_reset_color}( "
GIT_THEME_PROMPT_SUFFIX=" ${_omb_prompt_reset_color})"

OMB_THEME_PURITY_STATUS_BAD="${_omb_prompt_bold_brown}❯${_omb_prompt_reset_color}${_omb_prompt_normal} "
OMB_THEME_PURITY_STATUS_OK="${_omb_prompt_bold_green}❯${_omb_prompt_reset_color}${_omb_prompt_normal} "
_omb_deprecate_declare 20000 STATUS_THEME_PROMPT_BAD OMB_THEME_PURITY_STATUS_BAD sync
_omb_deprecate_declare 20000 STATUS_THEME_PROMPT_OK  OMB_THEME_PURITY_STATUS_OK  sync

function _omb_theme_PROMPT_COMMAND {
  if (($? == 0)); then
    local ret_status=${STATUS_THEME_PROMPT_OK:-${OMB_THEME_PURITY_STATUS_OK-}}
  else
    local ret_status=${STATUS_THEME_PROMPT_BAD:-${OMB_THEME_PURITY_STATUS_BAD-}}
  fi
  PS1="\n${_omb_prompt_navy}\w $(scm_prompt_info)\n${ret_status} "
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
