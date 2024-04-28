#! bash oh-my-bash.module

# Emoji-based theme to display source control management and
# virtual environment info beside the ordinary bash prompt.

# Theme inspired by:
#  - Bash_it cupcake theme

# Demo:
# ╭─ⓔ virtualenv 💁user at 💻 host in 📁directory on (🌿branch {1} ↑1 ↓1 +1 •1 ⌀1 ✗)
# ╰λ cd .bash-it/themes/lambda

# virtualenv prompts
VIRTUALENV_CHAR="ⓔ "
OMB_PROMPT_VIRTUALENV_FORMAT='%s'
OMB_PROMPT_SHOW_PYTHON_VENV=${OMB_PROMPT_SHOW_PYTHON_VENV:=true}

# SCM prompts
SCM_NONE_CHAR=""
SCM_GIT_CHAR="[±] "
SCM_GIT_BEHIND_CHAR="${_omb_prompt_brown}↓${_omb_prompt_normal}"
SCM_GIT_AHEAD_CHAR="${_omb_prompt_bold_green}↑${_omb_prompt_normal}"
SCM_GIT_UNTRACKED_CHAR="⌀"
SCM_GIT_UNSTAGED_CHAR="${_omb_prompt_bold_olive}•${_omb_prompt_normal}"
SCM_GIT_STAGED_CHAR="${_omb_prompt_bold_green}+${_omb_prompt_normal}"

SCM_THEME_PROMPT_DIRTY=""
SCM_THEME_PROMPT_CLEAN=""
SCM_THEME_PROMPT_PREFIX=""
SCM_THEME_PROMPT_SUFFIX=")"

# Git status prompts
GIT_THEME_PROMPT_DIRTY=" ${_omb_prompt_brown}✗${_omb_prompt_normal}"
GIT_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓${_omb_prompt_normal}"
GIT_THEME_PROMPT_PREFIX=""
GIT_THEME_PROMPT_SUFFIX=""

# ICONS =======================================================================

icon_start="╭─"
icon_user=" 💁 "
icon_host=" at 💻 "
icon_directory=" in 📁 "
icon_branch="🌿"
icon_end="╰λ "

# extra spaces ensure legiblity in prompt

# FUNCTIONS ===================================================================

# Rename tab
function tabname {
  printf "\e]1;$1\a"
}

# Rename window
function winname {
  printf "\e]2;$1\a"
}

# PROMPT OUTPUT ===============================================================

# Displays the current prompt
function _omb_theme_PROMPT_COMMAND() {
  PS1="${icon_start}$(_omb_prompt_print_python_venv)${icon_user}${_omb_prompt_bold_brown}\u${_omb_prompt_normal}${icon_host}${_omb_prompt_bold_teal}\h${_omb_prompt_normal}${icon_directory}${_omb_prompt_bold_purple}\w${_omb_prompt_normal}\$([[ -n \$(_omb_prompt_git branch 2> /dev/null) ]] && echo \" on (${icon_branch} \")${_omb_prompt_white}$(scm_prompt_info)${_omb_prompt_normal}\n${icon_end}"
  PS2="${icon_end}"
}

# Runs prompt (this bypasses oh-my-bash $PROMPT setting)
_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
