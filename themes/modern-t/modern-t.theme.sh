#! bash oh-my-bash.module
SCM_THEME_PROMPT_PREFIX=""
SCM_THEME_PROMPT_SUFFIX=""

SCM_THEME_PROMPT_DIRTY=" ${_omb_prompt_bold_brown}✗${_omb_prompt_normal}"
SCM_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓${_omb_prompt_normal}"
SCM_GIT_CHAR="${_omb_prompt_bold_green}±${_omb_prompt_normal}"
SCM_SVN_CHAR="${_omb_prompt_bold_teal}⑆${_omb_prompt_normal}"
SCM_HG_CHAR="${_omb_prompt_bold_brown}☿${_omb_prompt_normal}"

case $TERM in
	xterm*)
	TITLEBAR="\[\033]0;\w\007\]"
	;;
	*)
	TITLEBAR=""
	;;
esac

PS3=">> "

function is_vim_shell {
	if [ ! -z "$VIMRUNTIME" ]
	then
		echo "[${_omb_prompt_teal}vim shell${_omb_prompt_normal}]"
	fi
}

function modern_scm_prompt {
	CHAR=$(scm_char)
	if [ $CHAR = $SCM_NONE_CHAR ]
	then
		return
	else
		echo "[$(scm_char)][$(scm_prompt_info)]"
	fi
}

function _omb_theme_PROMPT_COMMAND {
	if (($? != 0)); then
    local border_color=$_omb_prompt_bold_brown
  else
    local border_color=$_omb_prompt_normal
  fi

  local todo_count=
  _omb_util_binary_exists t &&
    todo_count=[${_omb_prompt_teal}$(command t | wc -l | sed -e's/ *//')${_omb_prompt_reset_color}]

	PS1="${TITLEBAR}${border_color}┌─$todo_count${_omb_prompt_normal}$(modern_scm_prompt)[${_omb_prompt_teal}\W${_omb_prompt_normal}]$(is_vim_shell)"
  PS1+="\n${border_color}└─▪${_omb_prompt_normal} "
}

PS2="└─▪ "

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND

if [[ -t 2 ]] && ! _omb_util_binary_exists t; then
  printf '%s\n' "${_omb_term_bold_navy}oh-my-bash (theme:modern-t)${_omb_term_normal}: command \"t\" not found. The theme \"Modern T\" depends on a todo-list manager \"t\" (${_omb_term_underline}https://github.com/sjl/t${_omb_term_normal})." >&2
fi
