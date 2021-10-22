#!/usr/bin/env bash

# Theme inspired on:
#  - ys theme - https://github.com/ohmyzsh/ohmyzsh/blob/master/themes/ys.zsh-theme
#  - rana theme - https://github.com/ohmybash/oh-my-bash/blob/master/themes/rana/rana.theme.sh
#
# by Ziqiang Pei<ziqiangpei@foxmail.com>

# ----------------------------------------------------------------- COLOR CONF
D_DEFAULT_COLOR="${white}"
D_INTERMEDIATE_COLOR="${bold_white}"
D_NUMBER_COLOR="${bold_blue}"
D_USER_COLOR="${cyan}"
D_SUPERUSER_COLOR="${red}"
D_MACHINE_COLOR="${green}"
D_DIR_COLOR="${bold_yellow}"
D_GIT_DEFAULT_COLOR="${echo_white}"
D_GIT_BRANCH_COLOR="${echo_cyan}"
D_GIT_PROMPT_COLOR="${echo_red}"
D_SCM_COLOR="${bold_yellow}"
D_BRANCH_COLOR="${cyan}"
D_CHANGES_COLOR="${white}"
D_TIME_COLOR="${white}"
D_DOLLOR_COLOR="${bold_red}"
D_CMDFAIL_COLOR="${red}"
D_VIMSHELL_COLOR="${cyan}"

# ------------------------------------------------------------------ FUNCTIONS
case $TERM in
  xterm*)
      TITLEBAR="\033]0;\w\007"
      ;;
  *)
      TITLEBAR=""
      ;;
esac

is_vim_shell() {
  if [ ! -z "$VIMRUNTIME" ];
  then
    echo "${D_INTERMEDIATE_COLOR}on ${D_VIMSHELL_COLOR}\
vim shell${D_DEFAULT_COLOR} "
  fi
}

mitsuhikos_lastcommandfailed() {
  code=$?
  if [ $code != 0 ];
  then
    echo " ${D_DEFAULT_COLOR}C:${D_CMDFAIL_COLOR}\
$code ${D_DEFAULT_COLOR}"
  fi
}

# vcprompt for scm instead of oh-my-bash default
demula_vcprompt() {
  if [ ! -z "$VCPROMPT_EXECUTABLE" ];
  then
    local D_VCPROMPT_FORMAT="on ${D_SCM_COLOR}%s${D_INTERMEDIATE_COLOR}:\
${D_BRANCH_COLOR}%b %r ${D_CHANGES_COLOR}%m%u ${D_DEFAULT_COLOR}"
    $VCPROMPT_EXECUTABLE -f "$D_VCPROMPT_FORMAT"
  fi
}

# checks if the plugin is installed before calling battery_charge
safe_battery_charge() {
  if [ -e "${OSH}/plugins/battery/battery.plugin.sh" ];
  then
    battery_charge
  fi
}

prompt_git() {
	local s='';
	local branchName='';

	# Check if the current directory is in a Git repository.
	if [ $(git rev-parse --is-inside-work-tree &>/dev/null; echo "${?}") == '0' ]; then

		# check if the current directory is in .git before running git checks
		if [ "$(git rev-parse --is-inside-git-dir 2> /dev/null)" == 'false' ]; then

			# Ensure the index is up to date.
			git update-index --really-refresh -q &>/dev/null;

			# Check for uncommitted changes in the index.
			if ! $(git diff --quiet --ignore-submodules --cached); then
				s+='+';
			fi;

			# Check for unstaged changes.
			if ! $(git diff-files --quiet --ignore-submodules --); then
				s+='!';
			fi;

			# Check for untracked files.
			if [ -n "$(git ls-files --others --exclude-standard)" ]; then
				s+='?';
			fi;

			# Check for stashed files.
			if $(git rev-parse --verify refs/stash &>/dev/null); then
				s+='$';
			fi;

		fi;

		# Get the short symbolic ref.
		# If HEAD isn’t a symbolic ref, get the short SHA for the latest commit
		# Otherwise, just give up.
		branchName="$(git symbolic-ref --quiet --short HEAD 2> /dev/null || \
			git rev-parse --short HEAD 2> /dev/null || \
			echo '(unknown)')";

		[ -n "${s}" ] && s=" ${s}";

		echo -e "${D_GIT_DEFAULT_COLOR}on ${D_GIT_BRANCH_COLOR}${branchName}${D_GIT_PROMPT_COLOR}${s} ";
	else
		return;
	fi;
}

limited_pwd() {
  # Max length of PWD to display
  MAX_PWD_LENGTH=20

  # Replace $HOME with ~ if possible 
  RELATIVE_PWD=${PWD/#$HOME/\~}

  local offset=$((${#RELATIVE_PWD}-$MAX_PWD_LENGTH))

  if [ $offset -gt "0" ]
  then
      local truncated_symbol="..."
      TRUNCATED_PWD=${RELATIVE_PWD:$offset:$MAX_PWD_LENGTH}
      echo -e "${truncated_symbol}/${TRUNCATED_PWD#*/}"
  else
      echo -e "${RELATIVE_PWD}"
  fi
}

prompt_python() {
  # for virtualenv
  if [[ $VIRTUAL_ENV ]]; then
    virtualenv=`basename "$VIRTUAL_ENV"`
    VIRTUALENV_THEME_PROMPT_PREFIX='('
    VIRTUALENV_THEME_PROMPT_SUFFIX=')'
    echo -e "${VIRTUALENV_THEME_PROMPT_PREFIX}$virtualenv${VIRTUALENV_THEME_PROMPT_SUFFIX}"
  fi

  # for condaenv
  if [[ $CONDA_DEFAULT_ENV ]]; then
    echo -e "${CONDAENV_THEME_PROMPT_PREFIX}${CONDA_DEFAULT_ENV}${CONDAENV_THEME_PROMPT_SUFFIX}"
  fi
}

# -------------------------------------------------------------- PROMPT OUTPUT
prompt() {
  local LAST_COMMAND_FAILED=$(mitsuhikos_lastcommandfailed)
  local SAVE_CURSOR='\033[s'
  local RESTORE_CURSOR='\033[u'
  local MOVE_CURSOR_RIGHTMOST='\033[500C'
  local MOVE_CURSOR_5_LEFT='\033[5D'
  local THEME_CLOCK_FORMAT="%H:%M:%S %y-%m-%d"
  # Replace $HOME with ~ if possible 
  local RELATIVE_PWD=${PWD/#$HOME/\~}

  if [ $(uname) = "Linux" ];
  then
    PS1="${TITLEBAR}$(prompt_python)
${SAVE_CURSOR}${MOVE_CURSOR_RIGHTMOST}${MOVE_CURSOR_5_LEFT}\
$(safe_battery_charge)${RESTORE_CURSOR}\
${D_NUMBER_COLOR}# ${D_USER_COLOR}\u ${D_DEFAULT_COLOR}\
@ ${D_MACHINE_COLOR}\h ${D_DEFAULT_COLOR}\
in ${D_DIR_COLOR}${RELATIVE_PWD} ${D_INTERMEDIATE_COLOR}\
$(prompt_git)\
${D_TIME_COLOR}[$(clock_prompt)]\
${LAST_COMMAND_FAILED}\
$(demula_vcprompt)\
$(is_vim_shell)
${D_DOLLOR_COLOR}$ ${D_DEFAULT_COLOR}"
  else
    PS1="${TITLEBAR}$(prompt_python)
${D_NUMBER_COLOR}# ${D_USER_COLOR}\u ${D_DEFAULT_COLOR}\
@ ${D_MACHINE_COLOR}\h ${D_DEFAULT_COLOR}\
in ${D_DIR_COLOR}${RELATIVE_PWD} ${D_INTERMEDIATE_COLOR}\
$(prompt_git)\
${D_TIME_COLOR}[$(clock_prompt)]\
${LAST_COMMAND_FAILED}\
$(demula_vcprompt)\
$(is_vim_shell)\
$(safe_battery_charge)
${D_DOLLOR_COLOR}$ ${D_DEFAULT_COLOR}"
  fi

  PS2="${D_INTERMEDIATE_COLOR}$ ${D_DEFAULT_COLOR}"
}

# Runs prompt (this bypasses oh-my-bash $PROMPT setting)
safe_append_prompt_command prompt
