#! bash oh-my-bash.module
#
# Based on 'bobby' theme with the addition of python_venv
#

SCM_THEME_PROMPT_DIRTY=" ${_omb_prompt_brown}✗"
SCM_THEME_PROMPT_CLEAN=" ${_omb_prompt_green}✓"
SCM_THEME_PROMPT_PREFIX=" ${_omb_prompt_olive}|${_omb_prompt_reset_color}"
SCM_THEME_PROMPT_SUFFIX="${_omb_prompt_olive}|"

RVM_THEME_PROMPT_PREFIX="|"
RVM_THEME_PROMPT_SUFFIX="|"
OMB_PROMPT_VIRTUALENV_FORMAT='|%s|'
OMB_PROMPT_SHOW_PYTHON_VENV=${OMB_PROMPT_SHOW_PYTHON_VENV:=true}

function _omb_theme_PROMPT_COMMAND() {
    PS1="\n${_omb_prompt_green}$(_omb_prompt_print_python_venv)${_omb_prompt_brown}$(_omb_prompt_print_ruby_env) ${_omb_prompt_reset_color}\h ${_omb_prompt_red}in ${_omb_prompt_reset_color}\w\n${_omb_prompt_olive}$(scm_char)$(scm_prompt_info) ${_omb_prompt_olive}→${_omb_prompt_white} "
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
