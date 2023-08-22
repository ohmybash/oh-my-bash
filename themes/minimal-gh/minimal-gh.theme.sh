#! bash oh-my-bash.module
#
#========================================================================================
#
#  ###    ###  ##  ##     ##  ##  ###    ###    ###    ##             ####    ##   ##
#  ## #  # ##  ##  ####   ##  ##  ## #  # ##   ## ##   ##            ##       ##   ##
#  ##  ##  ##  ##  ##  ## ##  ##  ##  ##  ##  ##   ##  ##            ##  ###  #######
#  ##      ##  ##  ##    ###  ##  ##      ##  #######  ##            ##   ##  ##   ##
#  ##      ##  ##  ##     ##  ##  ##      ##  ##   ##  ######         ####    ##   ##
#
#========================================================================================
#
# Un tema creado por @AlexGh12 para el proyecto de @ohmybash en CDMX 🇲🇽
#

function _omb_theme_PROMPT_COMMAND() {

	local TITLEBAR
	case $TERM in
	xterm* | screen)
		TITLEBAR=$'\1\e]0;'$USER@${HOSTNAME%%.*}:${PWD/#$HOME/~}$'\e\\\2' ;;
	*)
		TITLEBAR= ;;
	esac

  local HORA=$(date +%H)
	local MERIDIANO
	if (( 10#$HORA > 12 )); then
		MERIDIANO="pm";
	else
		MERIDIANO="am";
	fi

	PS1=$TITLEBAR"\n${_omb_prompt_gray}\T${MERIDIANO} ${_omb_prompt_green}\u ${_omb_prompt_olive}\${PWD} $(scm_prompt_info)\n${_omb_prompt_gray}\$ ${_omb_prompt_white}"

}

SCM_THEME_PROMPT_DIRTY=" ${_omb_prompt_brown}✗"
SCM_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓"
SCM_THEME_PROMPT_PREFIX="${_omb_prompt_white}- ${_omb_prompt_bold_teal}"
SCM_THEME_PROMPT_SUFFIX=""

OMB_PROMPT_VIRTUALENV_FORMAT="${_omb_prompt_bold_gray}(%s)${_omb_prompt_reset_color}"
OMB_PROMPT_CONDAENV_FORMAT="${_omb_prompt_bold_gray}(%s)${_omb_prompt_reset_color}"

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
