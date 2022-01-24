#! bash oh-my-bash.module

SCM_THEME_PROMPT_DIRTY=" ${_omb_prompt_brown}✗"
SCM_THEME_PROMPT_CLEAN=" ${_omb_prompt_green}✓"
SCM_THEME_PROMPT_PREFIX=" ${_omb_prompt_navy}scm:( "
SCM_THEME_PROMPT_SUFFIX="${_omb_prompt_navy} )"

GIT_THEME_PROMPT_DIRTY=" ${_omb_prompt_brown}✗"
GIT_THEME_PROMPT_CLEAN=" ${_omb_prompt_green}✓"
GIT_THEME_PROMPT_PREFIX="${_omb_prompt_green}git:( "
GIT_THEME_PROMPT_SUFFIX="${_omb_prompt_green} )"

function git_prompt_info {
  git_prompt_vars
  echo -e "$SCM_PREFIX$SCM_BRANCH$SCM_STATE$SCM_SUFFIX"
}

function _omb_theme_PROMPT_COMMAND() {
  PS1="\h: \W $(scm_prompt_info)${_omb_prompt_reset_color} $ "
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
