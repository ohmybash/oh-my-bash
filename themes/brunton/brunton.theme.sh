#! bash oh-my-bash.module

SCM_THEME_PROMPT_PREFIX=""
SCM_THEME_PROMPT_SUFFIX=""

SCM_THEME_PROMPT_DIRTY=" ${_omb_prompt_bold_brown}✗${_omb_prompt_normal}"
SCM_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓${_omb_prompt_normal}"
SCM_GIT_CHAR="${_omb_prompt_bold_green}±${_omb_prompt_normal}"
SCM_SVN_CHAR="${_omb_prompt_bold_teal}⑆${_omb_prompt_normal}"
SCM_HG_CHAR="${_omb_prompt_bold_brown}☿${_omb_prompt_normal}"

function is_vim_shell {
	if [ ! -z "$VIMRUNTIME" ]
	then
		echo "[${_omb_prompt_teal}vim shell${_omb_prompt_normal}]"
	fi
}

function scm_prompt {
	CHAR=$(scm_char)
	if [ $CHAR = $SCM_NONE_CHAR ]
	then
		return
	else
		echo " $(scm_char) (${_omb_prompt_white}$(scm_prompt_info)${_omb_prompt_normal})"
	fi
}

function _omb_theme_PROMPT_COMMAND {
  PS1="${_omb_prompt_white}${_omb_prompt_background_navy} \u${_omb_prompt_normal}"
  PS1+="${_omb_prompt_background_navy}@${_omb_prompt_brown}${_omb_prompt_background_navy}\h $(clock_prompt) ${_omb_prompt_reset_color}"
  PS1+="${_omb_prompt_normal} $(battery_charge)\n"
  PS1+="${_omb_prompt_bold_black}${_omb_prompt_background_white} \w "
  PS1+="${_omb_prompt_normal}$(scm_prompt)$(is_vim_shell)\n"
  PS1+="${_omb_prompt_white}>${_omb_prompt_normal} "
}

THEME_CLOCK_COLOR=${THEME_CLOCK_COLOR:-"$_omb_prompt_navy$_omb_prompt_background_white"}
THEME_CLOCK_FORMAT=${THEME_CLOCK_FORMAT:-" %H:%M:%S"}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
