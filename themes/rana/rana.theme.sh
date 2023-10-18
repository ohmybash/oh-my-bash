#! bash oh-my-bash.module

# Theme inspired on:
#  - Ronacher's dotfiles (mitsuhikos) - http://github.com/mitsuhiko/dotfiles/tree/master/bash/
#  - Glenbot - http://theglenbot.com/custom-bash-shell-for-development/
#  - My extravagant zsh - http://stevelosh.com/blog/2010/02/my-extravagant-zsh-prompt/
#  - Monokai colors - http://monokai.nl/blog/2006/07/15/textmate-color-theme/
#  - Bash_it modern theme
#
# by Rana Amrit Parth <ramrit9@gmaiil.com>

# For the real Monokai colors you should add these to your .XDefaults or
# terminal configuration:
#! ----------------------------------------------------------- TERMINAL COLORS
#! monokai - http://www.monokai.nl/blog/2006/07/15/textmate-color-theme/
#*background: #272822
#*foreground: #E2DA6E
#*color0: black
#! mild red
#*color1: #CD0000
#! light green
#*color2: #A5E02D
#! orange (yellow)
#*color3: #FB951F
#! "dark" blue
#*color4: #076BCC
#! hot pink
#*color5: #F6266C
#! cyan
#*color6: #64D9ED
#! gray
#*color7: #E5E5E5

# ----------------------------------------------------------------- DEF COLOR

_omb_deprecate_const 20000 RCol "$_omb_prompt_normal"      "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_normal}"
_omb_deprecate_const 20000 Bla  "$_omb_prompt_black"       "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_black}"
_omb_deprecate_const 20000 Red  "$_omb_prompt_brown"       "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_brown}"
_omb_deprecate_const 20000 Gre  "$_omb_prompt_green"       "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_green}"
_omb_deprecate_const 20000 Yel  "$_omb_prompt_olive"       "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_olive}"
_omb_deprecate_const 20000 Blu  "$_omb_prompt_navy"        "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_navy}"
_omb_deprecate_const 20000 Pur  "$_omb_prompt_purple"      "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_purple}"
_omb_deprecate_const 20000 Cya  "$_omb_prompt_teal"        "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_teal}"
_omb_deprecate_const 20000 Whi  "$_omb_prompt_silver"      "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_silver}"
_omb_deprecate_const 20000 BBla "$_omb_prompt_bold_black"  "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_bold_black}"
_omb_deprecate_const 20000 BRed "$_omb_prompt_bold_brown"  "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_bold_brown}"
_omb_deprecate_const 20000 BGre "$_omb_prompt_bold_green"  "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_bold_green}"
_omb_deprecate_const 20000 BYel "$_omb_prompt_bold_olive"  "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_bold_olive}"
_omb_deprecate_const 20000 BBlu "$_omb_prompt_bold_navy"   "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_bold_navy}"
_omb_deprecate_const 20000 BPur "$_omb_prompt_bold_purple" "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_bold_purple}"
_omb_deprecate_const 20000 BCya "$_omb_prompt_bold_teal"   "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_bold_teal}"
_omb_deprecate_const 20000 BWhi "$_omb_prompt_bold_silver" "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_bold_silver}"
_omb_deprecate_const 20000 IBla "$_omb_prompt_gray"        "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_gray}"
_omb_deprecate_const 20000 IRed "$_omb_prompt_red"         "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_red}"
_omb_deprecate_const 20000 IGre "$_omb_prompt_lime"        "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_lime}"
_omb_deprecate_const 20000 IYel "$_omb_prompt_yellow"      "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_yellow}"
_omb_deprecate_const 20000 IBlu "$_omb_prompt_blue"        "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_blue}"
_omb_deprecate_const 20000 IPur "$_omb_prompt_magenta"     "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_magenta}"
_omb_deprecate_const 20000 ICya "$_omb_prompt_cyan"        "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_cyan}"
_omb_deprecate_const 20000 IWhi "$_omb_prompt_white"       "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_white}"

# ----------------------------------------------------------------- COLOR CONF
D_DEFAULT_COLOR="$_omb_prompt_silver"
D_INTERMEDIATE_COLOR="$_omb_prompt_bold_silver"
D_USER_COLOR="$_omb_prompt_olive"
D_SUPERUSER_COLOR="$_omb_prompt_brown"
D_MACHINE_COLOR="$_omb_prompt_yellow"
D_DIR_COLOR="$_omb_prompt_green"
D_GIT_COLOR="$_omb_prompt_bold_navy"
D_SCM_COLOR="$_omb_prompt_bold_olive"
D_BRANCH_COLOR="$_omb_prompt_bold_olive"
D_CHANGES_COLOR="$_omb_prompt_silver"
D_CMDFAIL_COLOR="$_omb_prompt_brown"
D_VIMSHELL_COLOR="$_omb_prompt_teal"

# ------------------------------------------------------------------ FUNCTIONS
case $TERM in
  xterm*)
    TITLEBAR='\[\e]0;\w\e\\\]'
    ;;
  *)
    TITLEBAR=""
    ;;
esac

function is_vim_shell {
  if [[ ${VIMRUNTIME-} ]]; then
    echo "${D_INTERMEDIATE_COLOR}on ${D_VIMSHELL_COLOR}vim shell${D_DEFAULT_COLOR} "
  fi
}

function mitsuhikos_lastcommandfailed {
  local status=$?
  if ((status != 0)); then
    echo "${D_INTERMEDIATE_COLOR}exited ${D_CMDFAIL_COLOR}$status ${D_DEFAULT_COLOR}"
  fi
}

# vcprompt for scm instead of oh-my-bash default
function demula_vcprompt {
  if [[ ${VCPROMPT_EXECUTABLE-} ]]; then
    local D_VCPROMPT_FORMAT="on ${D_SCM_COLOR}%s${D_INTERMEDIATE_COLOR}:${D_BRANCH_COLOR}%b %r ${D_CHANGES_COLOR}%m%u ${D_DEFAULT_COLOR}"
    $VCPROMPT_EXECUTABLE -f "$D_VCPROMPT_FORMAT"
  fi
}

# checks if the plugin is installed before calling battery_charge
function safe_battery_charge {
  if _omb_util_function_exists battery_charge; then
    battery_charge
  fi
}

function prompt_git {
  local s=''
  local branchName=''

  # Check if the current directory is in a Git repository.
  if _omb_prompt_git rev-parse --is-inside-work-tree &>/dev/null; then

    # check if the current directory is in .git before running git checks
    if [[ $(_omb_prompt_git rev-parse --is-inside-git-dir 2> /dev/null) == false ]]; then

      # Ensure the index is up to date.
      _omb_prompt_git update-index --really-refresh -q &>/dev/null

      # Check for uncommitted changes in the index.
      if ! _omb_prompt_git diff --quiet --ignore-submodules --cached; then
        s+='+'
      fi

      # Check for unstaged changes.
      if ! _omb_prompt_git diff-files --quiet --ignore-submodules --; then
        s+='!'
      fi

      # Check for untracked files.
      if [[ $(_omb_prompt_git ls-files --others --exclude-standard) ]]; then
        s+='?'
      fi

      # Check for stashed files.
      if _omb_prompt_git rev-parse --verify refs/stash &>/dev/null; then
        s+='$'
      fi

    fi

    # Get the short symbolic ref.
    # If HEAD isn’t a symbolic ref, get the short SHA for the latest commit
    # Otherwise, just give up.
    branchName=$(
      _omb_prompt_git symbolic-ref --quiet --short HEAD 2> /dev/null ||
        _omb_prompt_git rev-parse --short HEAD 2> /dev/null ||
        echo '(unknown)')

    [[ $s ]] && s=" [$s]"

    echo -e "${1}${branchName}${_omb_prompt_teal}$s"
  else
    return
  fi
}

# -------------------------------------------------------------- PROMPT OUTPUT
function _omb_theme_PROMPT_COMMAND {
  local LAST_COMMAND_FAILED=$(mitsuhikos_lastcommandfailed)
  local SAVE_CURSOR='\[\e7'
  local RESTORE_CURSOR='\e8\]'
  local MOVE_CURSOR_RIGHTMOST='\e['${COLUMNS:-9999}'C'
  local MOVE_CURSOR_5_LEFT='\e[5D'

  PS1=${TITLEBAR}$'\n'
  if [[ $OSTYPE == linux* ]]; then
    PS1+=${SAVE_CURSOR}${MOVE_CURSOR_RIGHTMOST}${MOVE_CURSOR_5_LEFT}
    PS1+=$(safe_battery_charge)${RESTORE_CURSOR}
  fi
  PS1+="${D_USER_COLOR}\u ${D_INTERMEDIATE_COLOR}"
  PS1+="at ${D_MACHINE_COLOR}\h ${D_INTERMEDIATE_COLOR}"
  PS1+="in ${D_DIR_COLOR}\w ${D_INTERMEDIATE_COLOR}"
  PS1+=$(prompt_git "$D_INTERMEDIATE_COLOR on $D_GIT_COLOR")
  PS1+=${LAST_COMMAND_FAILED}
  PS1+=$(demula_vcprompt)
  PS1+=$(is_vim_shell)
  if [[ $OSTYPE != linux* ]]; then
    PS1+=$(safe_battery_charge)
  fi
  PS1+=$'\n'"${D_INTERMEDIATE_COLOR}$ ${D_DEFAULT_COLOR}"

  PS2="${D_INTERMEDIATE_COLOR}$ ${D_DEFAULT_COLOR}"
}

# Runs prompt (this bypasses oh-my-bash $PROMPT setting)
_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
