#! bash oh-my-bash.module

SCM_THEME_PROMPT_DIRTY=" ${_omb_prompt_bold_brown}⊘${_omb_prompt_normal}"
SCM_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓${_omb_prompt_normal}"
SCM_THEME_PROMPT_PREFIX="${_omb_prompt_reset_color}( "
SCM_THEME_PROMPT_SUFFIX=" ${_omb_prompt_reset_color})"

GIT_THEME_PROMPT_DIRTY=" ${_omb_prompt_bold_brown}⊘${_omb_prompt_normal}"
GIT_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓${_omb_prompt_normal}"
GIT_THEME_PROMPT_PREFIX="${_omb_prompt_reset_color}( "
GIT_THEME_PROMPT_SUFFIX=" ${_omb_prompt_reset_color})"

STATUS_THEME_PROMPT_BAD="${_omb_prompt_bold_brown}❯${_omb_prompt_reset_color}${_omb_prompt_normal} "
STATUS_THEME_PROMPT_OK="${_omb_prompt_bold_green}❯${_omb_prompt_reset_color}${_omb_prompt_normal} "

function _omb_theme_PROMPT_COMMAND() {
    local ret_status="$( [ $? -eq 0 ] && echo -e "$STATUS_THEME_PROMPT_OK" || echo -e "$STATUS_THEME_PROMPT_BAD")"
    PS1="\n${_omb_prompt_navy}\w $(scm_prompt_info)\n${ret_status} "
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
