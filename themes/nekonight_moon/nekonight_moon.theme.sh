# nekonight-moon Bash prompt with source control management
# Author: Bruno Ciccarino <brunociccarinoo@gmail.com>
#
# Theme inspired by:
#  - Bash_it cupcake theme
# Demo:
# ╭─🌙 virtualenv 🌙user at 🌙host in 🌙directory on (🌙branch {1} ↑1 ↓1 +1 •1 ⌀1 ✗)
# ╰λ cd ~/path/to/your-directory

icon_start="╭─"
icon_user=" 🌙 ${_omb_prompt_bold_olive}\u${_omb_prompt_normal}"
icon_host=" at 🌙 ${_omb_prompt_bold_cyan}\h${_omb_prompt_normal}"
icon_directory=" in 🌙 ${_omb_prompt_bold_magenta}\w${_omb_prompt_normal}"
icon_end="╰─${_omb_prompt_bold_white}λ${_omb_prompt_normal}"

function _omb_theme_nekonight_git_prompt_info() {
  local branch_name
  branch_name=$(git symbolic-ref --short HEAD 2>/dev/null)
  local git_status=""

  if [[ -n $branch_name ]]; then
    git_status="${_omb_prompt_bold_white}(🌙 $branch_name $(_omb_theme_nekonight_scm_git_status))${_omb_prompt_normal}"
  fi

  echo -n "$git_status"
}

function _omb_theme_nekonight_scm_git_status() {
  local git_status=""

  if git rev-list --count --left-right @{upstream}...HEAD 2>/dev/null | grep -Eq '^[0-9]+\s[0-9]+$'; then
    git_status+="${_omb_prompt_brown}↓${_omb_prompt_normal} "
  fi

  if [[ -n $(git diff --cached --name-status 2>/dev/null) ]]; then
    git_status+="${_omb_prompt_green}+${_omb_prompt_normal}"
  fi

  if [[ -n $(git diff --name-status 2>/dev/null) ]]; then
    git_status+="${_omb_prompt_yellow}•${_omb_prompt_normal}"
  fi

  if [[ -n $(git ls-files --others --exclude-standard 2>/dev/null) ]]; then
    git_status+="${_omb_prompt_red}⌀${_omb_prompt_normal}"
  fi

  echo -n "$git_status"
}

function _omb_theme_PROMPT_COMMAND() {
  PS1="${icon_start}${icon_user}${icon_host}${icon_directory} in $(_omb_theme_nekonight_git_prompt_info)\n${icon_end} "
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
