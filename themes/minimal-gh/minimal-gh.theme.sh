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
  # Obtenemos IP segun el sistema operativo
  local IP
  case $OSTYPE in
  linux-gnu)
    # 2025-09-21 hostname is not a part of GNU/Linux.  In fact, Arch Linux
    # does not include "hostname" by default.
    # https://www.reddit.com/r/arch/comments/1nlv59f/bash_hostname_commend_not_found/
    { IP=$(ip addr 2>/dev/null | awk '$1 == "inet" {sub(/\/.*/, "", $2); if ($2 == "127.0.0.1") next; print $2; exit}'); [[ $IP ]]; } ||
      { IP=$(ip addr 2>/dev/null | awk '$1 == "inet6" {sub(/\/.*/, "", $2); if ($2 == "::1") next; print $2; exit}'); [[ $IP ]]; } ||
      IP=$(hostname -I 2>/dev/null | awk '{print $1}')
    ;;
  darwin*)
    IP=$(ifconfig en0 | awk '$1=="inet" {print $2}')
    ;;
  esac
  [[ $IP ]] || IP="127.0.0.1"  # Default to localhost if OS is not recognized

  local HORA=$(date +%H)
  local MERIDIANO
  if ((10#$HORA > 12)); then
    MERIDIANO="pm";
  else
    MERIDIANO="am";
  fi

  PS1="\n${_omb_prompt_gray}\T${MERIDIANO} ${_omb_prompt_green}\u@$IP ${_omb_prompt_gray}\h ${_omb_prompt_olive}\${PWD} $(scm_prompt_info)\n${_omb_prompt_gray}\$ ${_omb_prompt_normal}"
}

SCM_THEME_PROMPT_DIRTY=" ${_omb_prompt_brown}✗"
SCM_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓"
SCM_THEME_PROMPT_PREFIX="${_omb_prompt_white}- ${_omb_prompt_bold_teal}"
SCM_THEME_PROMPT_SUFFIX=""

OMB_PROMPT_VIRTUALENV_FORMAT="${_omb_prompt_bold_gray}(%s)${_omb_prompt_reset_color}"
OMB_PROMPT_CONDAENV_FORMAT="${_omb_prompt_bold_gray}(%s)${_omb_prompt_reset_color}"

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
