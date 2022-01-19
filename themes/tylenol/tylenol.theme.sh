#! bash oh-my-bash.module
#
# Based on 'bobby' theme with the addition of python_venv
#

SCM_THEME_PROMPT_DIRTY=" ${_omb_prompt_red}✗"
SCM_THEME_PROMPT_CLEAN=" ${_omb_prompt_green}✓"
SCM_THEME_PROMPT_PREFIX=" ${_omb_prompt_yellow}|${_omb_prompt_reset_color}"
SCM_THEME_PROMPT_SUFFIX="${_omb_prompt_yellow}|"

RVM_THEME_PROMPT_PREFIX="|"
RVM_THEME_PROMPT_SUFFIX="|"
VIRTUALENV_THEME_PROMPT_PREFIX='|'
VIRTUALENV_THEME_PROMPT_SUFFIX='|'

function _omb_theme_PROMPT_COMMAND() {
    PS1="\n${_omb_prompt_green}$(_omb_prompt_print_python_venv)${_omb_prompt_red}$(_omb_prompt_print_ruby_env) ${_omb_prompt_reset_color}\h ${_omb_prompt_orange}in ${_omb_prompt_reset_color}\w\n${_omb_prompt_yellow}$(scm_char)$(scm_prompt_info) ${_omb_prompt_yellow}→${_omb_prompt_white} "
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
