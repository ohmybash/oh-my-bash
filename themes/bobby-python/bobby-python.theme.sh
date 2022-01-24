#! bash oh-my-bash.module
SCM_THEME_PROMPT_DIRTY=" ${_omb_prompt_brown}✗"
SCM_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓"
SCM_THEME_PROMPT_PREFIX=" |"
SCM_THEME_PROMPT_SUFFIX="${_omb_prompt_green}|"

GIT_THEME_PROMPT_DIRTY=" ${_omb_prompt_brown}✗"
GIT_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓"
GIT_THEME_PROMPT_PREFIX=" ${_omb_prompt_green}|"
GIT_THEME_PROMPT_SUFFIX="${_omb_prompt_green}|"

CONDAENV_THEME_PROMPT_SUFFIX="|"

function _omb_theme_PROMPT_COMMAND() {
    #PS1="${_omb_prompt_bold_teal}$(scm_char)${_omb_prompt_green}$(scm_prompt_info)${_omb_prompt_purple}$(_omb_prompt_print_ruby_env) ${_omb_prompt_olive}\h ${_omb_prompt_reset_color}in ${_omb_prompt_green}\w ${_omb_prompt_reset_color}\n${_omb_prompt_green}→${_omb_prompt_reset_color} "
    PS1="\n${_omb_prompt_olive}$(python_version_prompt) ${_omb_prompt_purple}\h ${_omb_prompt_reset_color}in ${_omb_prompt_green}\w\n${_omb_prompt_bold_teal}$(scm_char)${_omb_prompt_green}$(scm_prompt_info) ${_omb_prompt_green}→${_omb_prompt_reset_color} "
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
