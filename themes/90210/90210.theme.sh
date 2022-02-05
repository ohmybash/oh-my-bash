#! bash oh-my-bash.module
SCM_THEME_PROMPT_DIRTY=" ${_omb_prompt_brown}✗"
SCM_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓"
SCM_THEME_PROMPT_PREFIX=" |"
SCM_THEME_PROMPT_SUFFIX="${_omb_prompt_green}|"

GIT_THEME_PROMPT_DIRTY=" ${_omb_prompt_brown}✗"
GIT_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓"
GIT_THEME_PROMPT_PREFIX=" ${_omb_prompt_green}|"
GIT_THEME_PROMPT_SUFFIX="${_omb_prompt_green}|"

# Nicely formatted terminal prompt
function _omb_theme_PROMPT_COMMAND(){
  PS1="\n${_omb_prompt_bold_gray}[${_omb_prompt_navy}\@${_omb_prompt_bold_gray}]-"
  PS1+="${_omb_prompt_bold_gray}[${_omb_prompt_green}\u${_omb_prompt_olive}@${_omb_prompt_green}\h${_omb_prompt_bold_gray}]-"
  PS1+="${_omb_prompt_bold_gray}[${_omb_prompt_purple}\w${_omb_prompt_bold_gray}]-"
  PS1+="$(scm_prompt_info)\n${_omb_prompt_reset_color}\$ "
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
