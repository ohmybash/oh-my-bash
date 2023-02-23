#! bash oh-my-bash.module

# rr is a simple one-liner prompt inspired by robbyrussell from ohmyzsh themes.
#
# Looks:
#
# ➜  anish ~ cd .bash-it/themes/dulcie
# ➜  anish custom-dulcie git:(master ✓) # with git
#
# Configuration. Change these by adding them in your .bash_profile

OMB_PROMPT_SHOW_PYTHON_VENV=${OMB_PROMPT_SHOW_PYTHON_VENV:=false}
OMB_PROMPT_VIRTUALENV_FORMAT="${_omb_prompt_bold_purple}vitualenv:(${_omb_prompt_reset_color}%s${_omb_prompt_bold_purple}) ${_omb_prompt_reset_color}"
OMB_PROMPT_CONDAENV_FORMAT="${_omb_prompt_bold_purple}condaenv:(${_omb_prompt_reset_color}%s${_omb_prompt_bold_purple}) ${_omb_prompt_reset_color}"

function _omb_theme_PROMPT_COMMAND() {
  local arrow="${_omb_prompt_bold_purple}➜${_omb_prompt_reset_color}"
  local user_name="${_omb_prompt_white}\u${_omb_prompt_reset_color}"
  local base_directory="${_omb_prompt_bold_blue}\W${_omb_prompt_reset_color}"
  local GIT_THEME_PROMPT_PREFIX="${_omb_prompt_bold_purple}git:(${_omb_prompt_reset_color}"
  local SVN_THEME_PROMPT_PREFIX="${_omb_prompt_bold_purple}svn:(${_omb_prompt_reset_color}"
  local HG_THEME_PROMPT_PREFIX="${_omb_prompt_bold_purple}hg:(${_omb_prompt_reset_color}"
  local SCM_THEME_PROMPT_SUFFIX="${_omb_prompt_bold_purple})${_omb_prompt_reset_color}"
  local SCM_THEME_PROMPT_CLEAN="${_omb_prompt_bold_green} ✓${_omb_prompt_reset_color}"
  local SCM_THEME_PROMPT_DIRTY="${_omb_prompt_bold_red} ✗${_omb_prompt_reset_color}"

  PS1="${arrow}  ${user_name} ${base_directory} "

  local python_venv
  _omb_prompt_get_python_venv
  PS1+=$python_venv

  local scm_info=$(scm_prompt_info)
  PS1+=${scm_info:+$scm_info }
  PS1+=$_omb_prompt_normal
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
