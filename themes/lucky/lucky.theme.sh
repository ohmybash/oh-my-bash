#! bash oh-my-bash.module

# Oh My Bash Theme: lucky
# Author: meizikeai@163.com
# Description: A minimal theme with Git status, Python venv, and hostname info.

SCM_GIT_SHOW_MINIMAL_INFO=${SCM_GIT_SHOW_MINIMAL_INFO:-true}
SCM_THEME_PROMPT_CLEAN=$_omb_prompt_green${SCM_THEME_PROMPT_CLEAN:-'✔'}
SCM_THEME_PROMPT_DIRTY=$_omb_prompt_brown${SCM_THEME_PROMPT_DIRTY:-'✘'}
SCM_THEME_BRANCH_PREFIX=${SCM_THEME_BRANCH_PREFIX:-:}
SCM_THEME_PROMPT_PREFIX=' '$_omb_prompt_white'on '$_omb_prompt_navy'git'$_omb_prompt_purple
SCM_THEME_PROMPT_SUFFIX=$_omb_prompt_normal

function _omb_theme_PROMPT_COMMAND() {
  local python_venv
  _omb_prompt_get_python_venv
  PS1=$python_venv
  PS1+=$_omb_prompt_teal'\u '$_omb_prompt_white'@ '$_omb_prompt_green'\h '
  PS1+=$_omb_prompt_white'in '$_omb_prompt_bold_olive'\w'
  PS1+=$(scm_prompt_info)
  PS1+=$_omb_prompt_white' ['$(clock_prompt)$_omb_prompt_white']\n'
  PS1+=$_omb_prompt_bold_brown'\$ '$_omb_prompt_normal
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
