#! bash oh-my-bash.module

# Axin Bash Prompt, inspired by theme "Sexy" and "Bobby"
# thanks to them

if [[ $COLORTERM = gnome-* && $TERM = xterm ]] && infocmp gnome-256color &>/dev/null; then
  export TERM=gnome-256color
elif [[ $TERM != dumb ]] && infocmp xterm-256color &>/dev/null; then
  export TERM=xterm-256color
fi

MAGENTA=$_omb_prompt_bold_red
WHITE=$_omb_prompt_bold_silver
ORANGE=$_omb_prompt_bold_olive
GREEN=$_omb_prompt_bold_green
PURPLE=$_omb_prompt_bold_purple
RESET=$_omb_prompt_normal
if ((_omb_term_colors >= 256)); then
  ORANGE=$_omb_prompt_bold'\['$(tput setaf 172)'\]'
  GREEN=$_omb_prompt_bold'\['$(tput setaf 190)'\]'
  PURPLE=$_omb_prompt_bold'\['$(tput setaf 141)'\]'
fi

OMB_PROMPT_VIRTUALENV_FORMAT='( %s ) '
OMB_PROMPT_CONDAENV_FORMAT='( %s ) '
OMB_PROMPT_CONDAENV_USE_BASENAME=true
OMB_PROMPT_SHOW_PYTHON_VENV=${OMB_PROMPT_SHOW_PYTHON_VENV:=false}

function _omb_theme_PROMPT_COMMAND() {
  local python_venv
  _omb_prompt_get_python_venv
  PS1="$python_venv${MAGENTA}\u ${WHITE}@ ${ORANGE}\h ${WHITE}in ${GREEN}\w${WHITE}$SCM_THEME_PROMPT_PREFIX$(clock_prompt) ${PURPLE}\$(scm_prompt_info) \n\$ ${RESET}"
}

THEME_CLOCK_COLOR=${THEME_CLOCK_COLOR:-"${_omb_prompt_white}"}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
