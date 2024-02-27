#! bash oh-my-bash.module

# This theme attempts to replicate the default "robbyrussell" theme from ohmyzsh:
#  https://github.com/ohmyzsh/ohmyzsh/blob/master/themes/robbyrussell.zsh-theme

# Example outside git repo:
# ➜  ~
#
# Example inside clean git repo:
# ➜  config-files git:(main)
#
# Example inside dirty git repo:
# ➜  config-files git:(main ?:1) ✗
#
# Example with virtual environment:
# ➜  (env1) ~
# 
# Example with virtual environment and inside git repo:
# ➜  (env1) config-files git:(main)
#

# python_venv setup
OMB_PROMPT_VIRTUALENV_FORMAT='(%s) '
omb_prompt_show_python_venv=${omb_prompt_show_python_venv:=true}

function _omb_theme_PROMPT_COMMAND() {
    if [[ "$?" == 0 ]]; then
        local arrow_color="${_omb_prompt_bold_green}"
    else
        local arrow_color="${_omb_prompt_bold_brown}"
    fi
    
    # set the python_venv format
    local python_venv; _omb_prompt_get_python_venv
    python_venv="$_omb_prompt_olive$python_venv"

    local base_directory="${_omb_prompt_bold_teal}\W${_omb_prompt_reset_color}"
    local GIT_THEME_PROMPT_PREFIX="${_omb_prompt_bold_navy}git:(${_omb_prompt_bold_brown}"
    local SVN_THEME_PROMPT_PREFIX="${_omb_prompt_bold_navy}svn:(${_omb_prompt_bold_brown}"
    local HG_THEME_PROMPT_PREFIX="${_omb_prompt_bold_navy}hg:(${_omb_prompt_bold_brown}"
    local SCM_THEME_PROMPT_SUFFIX="${_omb_prompt_reset_color}"
    local SCM_THEME_PROMPT_CLEAN="${_omb_prompt_bold_navy})${_omb_prompt_reset_color}"
    local SCM_THEME_PROMPT_DIRTY="${_omb_prompt_bold_navy}) ${_omb_prompt_olive}✗${_omb_prompt_reset_color}"

    local arrow="${arrow_color}➜${_omb_prompt_reset_color}"

    PS1="${arrow}  ${python_venv}${base_directory} "

    local scm_info=$(scm_prompt_info)

    PS1+=${scm_info:+$scm_info }
    PS1+=${_omb_prompt_normal}
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
