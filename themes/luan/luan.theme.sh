#! bash oh-my-bash.module

SCM_THEME_PROMPT_DIRTY=" ${_omb_prompt_brown}✗"
SCM_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓"
SCM_THEME_PROMPT_PREFIX="(${_omb_prompt_olive}"
SCM_THEME_PROMPT_SUFFIX="${_omb_prompt_normal})"

GIT_THEME_PROMPT_DIRTY=" ${_omb_prompt_brown}✗"
GIT_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓"
GIT_THEME_PROMPT_PREFIX="(${_omb_prompt_olive}"
GIT_THEME_PROMPT_SUFFIX="${_omb_prompt_normal})"

OMB_PROMPT_RVM_FORMAT="%s"
OMB_PROMPT_VIRTUALENV_FORMAT='(%s) '
OMB_PROMPT_SHOW_PYTHON_VENV=${OMB_PROMPT_SHOW_PYTHON_VENV:=false}

function _omb_theme_PROMPT_COMMAND() {
  local dtime="$(clock_prompt)"
  local user_host="${_omb_prompt_green}\u@${_omb_prompt_teal}\h${_omb_prompt_normal}"
  local current_dir="${_omb_prompt_bold_navy}\w${_omb_prompt_normal}"
  local ruby_env python_venv
  _omb_prompt_get_ruby_env && ruby_env="$_omb_prompt_bold_brown$ruby_env$_omb_prompt_normal "
  _omb_prompt_get_python_venv
  local git_branch="$(scm_prompt_info)${_omb_prompt_normal}"
  local prompt="${_omb_prompt_bold_green}\$${_omb_prompt_normal} "
  local arrow="${_omb_prompt_bold_white}▶${_omb_prompt_normal} "
  local prompt="${_omb_prompt_bold_green}\$${_omb_prompt_normal} "

  PS1="${dtime}${user_host}:${current_dir} ${python_venv}${ruby_env}${git_branch}
      $arrow $prompt"
}

THEME_CLOCK_COLOR=${THEME_CLOCK_COLOR:-"$_omb_prompt_olive"}
THEME_CLOCK_FORMAT=${THEME_TIME_FORMAT:-"%I:%M:%S "}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
