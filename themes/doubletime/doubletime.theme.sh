#! bash oh-my-bash.module

SCM_THEME_PROMPT_DIRTY=''
SCM_THEME_PROMPT_CLEAN=''
SCM_GIT_CHAR="${_omb_prompt_bold_teal}±${_omb_prompt_normal}"
SCM_SVN_CHAR="${_omb_prompt_bold_teal}⑆${_omb_prompt_normal}"
SCM_HG_CHAR="${_omb_prompt_bold_brown}☿${_omb_prompt_normal}"
SCM_THEME_PROMPT_PREFIX=""
SCM_THEME_PROMPT_SUFFIX=""
if [ ! -z $RVM_THEME_PROMPT_COLOR ]; then
    RVM_THEME_PROMPT_COLOR=$(eval echo $`echo ${RVM_THEME_PROMPT_COLOR}`);
else
    RVM_THEME_PROMPT_COLOR="${_omb_prompt_brown}"
fi
RVM_THEME_PROMPT_PREFIX="(${RVM_THEME_PROMPT_COLOR}rb${_omb_prompt_normal}: "
RVM_THEME_PROMPT_SUFFIX=") "
if [ ! -z $VIRTUALENV_THEME_PROMPT_COLOR ]; then
    VIRTUALENV_THEME_PROMPT_COLOR=$(eval echo $`echo ${VIRTUALENV_THEME_PROMPT_COLOR}`);
else
    VIRTUALENV_THEME_PROMPT_COLOR="${_omb_prompt_green}"
fi
OMB_PROMPT_VIRTUALENV_FORMAT="(${VIRTUALENV_THEME_PROMPT_COLOR}py${_omb_prompt_normal}: %s) "
OMB_PROMPT_SHOW_PYTHON_VENV=${OMB_PROMPT_SHOW_PYTHON_VENV:=true}

if [ ! -z $THEME_PROMPT_HOST_COLOR ]; then
    THEME_PROMPT_HOST_COLOR=$(eval echo $`echo ${THEME_PROMPT_HOST_COLOR}`);
else
    THEME_PROMPT_HOST_COLOR="$_omb_prompt_navy"
fi

function doubletime_scm_prompt {
  CHAR=$(scm_char)
  if [ $CHAR = $SCM_NONE_CHAR ]; then
    return
  elif [ $CHAR = $SCM_GIT_CHAR ]; then
    echo "$(git_prompt_status)"
  else
    echo "[$(scm_prompt_info)]"
  fi
}

function _omb_theme_PROMPT_COMMAND() {
  # Save history
  history -a
  history -c
  history -r
  PS1="
$(clock_prompt) $(scm_char) [${THEME_PROMPT_HOST_COLOR}\u@${THEME_PROMPT_HOST}$_omb_prompt_reset_color] $(_omb_prompt_print_python_venv)$(_omb_prompt_print_ruby_env)\w
$(doubletime_scm_prompt)$_omb_prompt_reset_color $ "
  PS2='> '
  PS4='+ '
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND

function git_prompt_status {
  local git_status_output
  git_status_output=$(_omb_prompt_git status 2> /dev/null )
  if [ -n "$(echo $git_status_output | grep 'Changes not staged')" ]; then
    git_status="${_omb_prompt_bold_brown}$(scm_prompt_info) ✗"
  elif [ -n "$(echo $git_status_output | grep 'Changes to be committed')" ]; then
     git_status="${_omb_prompt_bold_olive}$(scm_prompt_info) ^"
  elif [ -n "$(echo $git_status_output | grep 'Untracked files')" ]; then
     git_status="${_omb_prompt_bold_teal}$(scm_prompt_info) +"
  elif [ -n "$(echo $git_status_output | grep 'nothing to commit')" ]; then
     git_status="${_omb_prompt_bold_green}$(scm_prompt_info) ${_omb_prompt_green}✓"
  else
    git_status="$(scm_prompt_info)"
  fi
  echo "[$git_status${_omb_prompt_normal}]"

}
