#! bash oh-my-bash.module

SCM_THEME_PROMPT_PREFIX="${_omb_prompt_teal} on ${_omb_prompt_green}"
SCM_THEME_PROMPT_SUFFIX=""
SCM_THEME_PROMPT_DIRTY=" ${_omb_prompt_brown}with changes"
SCM_THEME_PROMPT_CLEAN=""

function venv {
  if [ -n "$VIRTUAL_ENV" ]
  then
    local env=$VIRTUAL_ENV
    echo "${gray} in ${_omb_prompt_red}${env##*/} "
  fi
}

function last_two_dirs {
  pwd|rev|awk -F / '{print $1,$2}'|rev|sed s_\ _/_|sed "s|$(sed 's,\/,,'<<<"$HOME")|~|g"
}

function _omb_theme_PROMPT_COMMAND {
  PS1="${_omb_prompt_olive}# ${_omb_prompt_reset_color}$(last_two_dirs)$(scm_prompt_info)${_omb_prompt_reset_color}$(venv)${_omb_prompt_reset_color} ${_omb_prompt_teal}\n> ${_omb_prompt_reset_color}"
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
