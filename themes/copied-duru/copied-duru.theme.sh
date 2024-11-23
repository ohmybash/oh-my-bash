#! bash oh-my-bash.module
# "Copied-Duru" Prompt, inspired by "Sexy" and obviously "Duru"

source "$OSH/themes/sexy/sexy.theme.sh"

if [[ $COLORTERM = gnome-* && $TERM = xterm ]] && infocmp gnome-256color &>/dev/null; then
  export TERM=gnome-256color
elif [[ $TERM != dumb ]] && infocmp xterm-256color &>/dev/null; then
  export TERM=xterm-256color
fi

function _omb_theme_PROMPT_COMMAND {
	local current_time="\D{%H:%M:%S}"
	local python_venv=""
  local just_a_format=" ${MAGENTA}(%s)"

	if [[ -n "$VIRTUAL_ENV" ]]; then
    python_venv=$(printf "$just_a_format" "${VIRTUAL_ENV##*/}")
  elif [[ -n "$CONDA_DEFAULT_ENV" ]]; then
    python_venv=$(printf "$just_a_format" "${CONDA_DEFAULT_ENV##*/}")
  fi

	local git_prefix=$([[ -n $(_omb_prompt_git branch 2> /dev/null) ]] && _omb_util_print ' on ')
  
  PS1="${GREEN}#${python_venv} ${PURPLE}\u@${WHITE}\h${GREEN} ${current_time}>${RESET} ${PURPLE}<\w${WHITE}${git_prefix}${MAGENTA}$(parse_git_branch)${PURPLE}>${RESET}\n${GREEN}$ ${RESET}"
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND