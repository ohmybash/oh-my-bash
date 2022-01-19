#! bash oh-my-bash.module

SCM_THEME_PROMPT_PREFIX="${_omb_prompt_cyan} on ${_omb_prompt_green}"
SCM_THEME_PROMPT_SUFFIX=""
SCM_THEME_PROMPT_DIRTY=" ${_omb_prompt_red}with changes"
SCM_THEME_PROMPT_CLEAN=""

venv() {
  if [ ! -z "$VIRTUAL_ENV" ]
  then
    local env=$VIRTUAL_ENV
    echo "${gray} in ${_omb_prompt_orange}${env##*/} "
  fi
}

last_two_dirs() {
  pwd|rev|awk -F / '{print $1,$2}'|rev|sed s_\ _/_|sed "s|$(sed 's,\/,,'<<<$HOME)|~|g"
}

_omb_theme_PROMPT_COMMAND() {
  PS1="${_omb_prompt_yellow}# ${_omb_prompt_reset_color}$(last_two_dirs)$(scm_prompt_info)${_omb_prompt_reset_color}$(venv)${_omb_prompt_reset_color} ${_omb_prompt_cyan}\n> ${_omb_prompt_reset_color}"
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
