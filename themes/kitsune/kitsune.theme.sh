#! bash oh-my-bash.module
# This is combination of works from two different people which I combined for my requirement.
# Original PS1 was from reddit user /u/Allevil669 which I found in thread: https://www.reddit.com/r/linux/comments/1z33lj/linux_users_whats_your_favourite_bash_prompt/
# I used that PS1 to the bash-it theme 'morris', and customized it to my liking. All credits to /u/Allevil669 and morris.
#
# prompt theming

_omb_module_require plugin:battery

function prompt_command() {
  local status=$?

  # added TITLEBAR for updating the tab and window titles with the pwd
  local TITLEBAR
  case $TERM in
  xterm* | screen)
    TITLEBAR=$'\1\e]0;'$USER@${HOSTNAME%%.*}:${PWD/#$HOME/~}$'\e\\\2' ;;
  *)
    TITLEBAR= ;;
  esac

  local SC
  if ((status == 0)); then
    SC="$cyan-$bold_green(${green}^_^$bold_green)";
  else
    SC="$cyan-$bold_green(${red}T_T$bold_green)";
  fi

  local BC=$(battery_percentage)
  [[ $BC == no && $BC == -1 ]] && BC=
  BC=${BC:+${cyan}-${green}($BC%)}

  PS1=$TITLEBAR"\n${cyan}┌─${bold_white}[\u@\h]${cyan}─${bold_yellow}(\w)$(scm_prompt_info)\n${cyan}└─${bold_green}[\A]$SC$BC${cyan}-${bold_cyan}[${green}${bold_green}\$${bold_cyan}]${green} "
}

# scm theming
SCM_THEME_PROMPT_DIRTY=" ${red}✗"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓"
SCM_THEME_PROMPT_PREFIX="${bold_cyan}("
SCM_THEME_PROMPT_SUFFIX="${bold_cyan})${reset_color}"


_omb_util_add_prompt_command prompt_command
