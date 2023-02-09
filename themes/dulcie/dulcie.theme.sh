#! bash oh-my-bash.module

# Simplistic one-liner theme to display source control management info beside
# the ordinary Linux bash prompt.
#
# Demo:
#
# [ritola@localhost ~]$ cd .bash-it/themes/dulcie
# [ritola@localhost |master ✓| dulcie]$ # This is single line mode
# |bash-it|± master ✓|
# [ritola@localhost dulcie]$ # In multi line, the SCM info is in the separate line
#
# Configuration. Change these by adding them in your .bash_profile

DULCIE_COLOR=${DULCIE_COLOR:=1} # 0 = monochrome, 1 = colorful
DULCIE_MULTILINE=${DULCIE_MULTILINE:=1} # 0 = Single line, 1 = SCM in separate line

function dulcie_color {
  echo -en "\[\e[38;5;${1}m\]"
}

function dulcie_background {
  echo -en "\[\e[48;5;${1}m\]"
}

function _omb_theme_PROMPT_COMMAND {
  color_user_root=$(dulcie_color 169)
  color_user_nonroot="${_omb_prompt_green}"
  color_host_local=$(dulcie_color 230)
  color_host_remote=$(dulcie_color 214)
  color_rootdir=$(dulcie_color 117)
  color_workingdir=$(dulcie_color 117)
  background_scm=$(dulcie_background 238)

  SCM_THEME_ROOT_SUFFIX="|$(scm_char) "

  # Set colors
  if [ "${DULCIE_COLOR}" -eq "1" ]; then
    if [[ $EUID -ne 0 ]]; then
      color_user="${color_user_nonroot}"
    else
      color_user="${color_user_root}"
    fi

    if [[ -n "${SSH_CLIENT}" ]]; then
      color_host="${color_host_remote}"
    else
      color_host="${color_host_local}"
    fi

    DULCIE_USER="${color_user}\u${_omb_prompt_reset_color}"
    DULCIE_HOST="${color_host}\h${_omb_prompt_reset_color}"
    DULCIE_WORKINGDIR="${color_workingdir}\W${_omb_prompt_reset_color}"
    DULCIE_PROMPTCHAR="${color_user}"'\$'"${_omb_prompt_reset_color}"

    SCM_THEME_PROMPT_DIRTY=" ${_omb_prompt_brown}✗${_omb_prompt_reset_color}"
    SCM_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓${_omb_prompt_normal}"
    DULCIE_SCM_BACKGROUND="${background_scm}"
    DULCIE_SCM_DIR_COLOR="${color_rootdir}"
    SCM_THEME_ROOT_SUFFIX="${_omb_prompt_reset_color}${SCM_THEME_ROOT_SUFFIX}"
    SCM_THEME_PROMPT_DIRTY=" $(dulcie_color 1)✗${_omb_prompt_reset_color}"
    SCM_THEME_PROMPT_CLEAN=" $(dulcie_color 10)✓${_omb_prompt_reset_color}"
  else
    DULCIE_USER='\u'
    DULCIE_HOST='\h'
    DULCIE_WORKINGDIR='\W'
    DULCIE_PROMPTCHAR='\$'

    DULCIE_SCM_BACKGROUND=""
    DULCIE_SCM_DIR_COLOR=""
    SCM_THEME_DIR_COLOR=""
    SCM_THEME_PROMPT_DIRTY=" ✗"
    SCM_THEME_PROMPT_CLEAN=" ✓"
  fi

  # Change terminal title
  printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"

  # Open the new terminal in the same directory
  _omb_util_function_exists __vte_osc7 && __vte_osc7

  PS1="${_omb_prompt_reset_color}[${DULCIE_USER}@${DULCIE_HOST}$(scm_prompt_info)${_omb_prompt_reset_color} ${DULCIE_WORKINGDIR}]"
  if [[ "${DULCIE_MULTILINE}" -eq "1" ]]; then
    PS1="${_omb_prompt_reset_color}[${DULCIE_USER}@${DULCIE_HOST}${_omb_prompt_reset_color} ${DULCIE_WORKINGDIR}]"
    if [[ "$(scm_prompt_info)" ]]; then
      SCM_THEME_PROMPT_PREFIX="${DULCIE_SCM_BACKGROUND}|${DULCIE_SCM_DIR_COLOR}"
      SCM_THEME_PROMPT_SUFFIX="|${_omb_prompt_normal}"
      PS1="$(scm_prompt_info)\n${PS1}"
    fi
  else
    SCM_THEME_PROMPT_PREFIX=" ${DULCIE_SCM_BACKGROUND}|${DULCIE_SCM_DIR_COLOR}"
    SCM_THEME_PROMPT_SUFFIX="|${_omb_prompt_normal}"
    PS1="${_omb_prompt_reset_color}[${DULCIE_USER}@${DULCIE_HOST}$(scm_prompt_info)${_omb_prompt_reset_color} ${DULCIE_WORKINGDIR}]"
  fi
  PS1="${PS1}${DULCIE_PROMPTCHAR} "
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
