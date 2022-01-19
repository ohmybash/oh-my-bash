#! bash oh-my-bash.module
SCM_THEME_PROMPT_DIRTY=" ${red}✗"
SCM_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓"
SCM_THEME_PROMPT_PREFIX=" |"
SCM_THEME_PROMPT_SUFFIX="${green}|"

GIT_THEME_PROMPT_DIRTY=" ${red}✗"
GIT_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓"
GIT_THEME_PROMPT_PREFIX=" ${green}|"
GIT_THEME_PROMPT_SUFFIX="${green}|"

# Nicely formatted terminal prompt
function _omb_theme_PROMPT_COMMAND(){
  export PS1="\n${_omb_prompt_bold_black}[${blue}\@${_omb_prompt_bold_black}]-${_omb_prompt_bold_black}[${green}\u${yellow}@${green}\h${_omb_prompt_bold_black}]-${_omb_prompt_bold_black}[${purple}\w${_omb_prompt_bold_black}]-$(scm_prompt_info)\n${_omb_prompt_reset_color}\$ "
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
