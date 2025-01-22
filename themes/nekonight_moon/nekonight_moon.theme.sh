# nekonight-moon Bash prompt with source control management
# Author: Bruno Ciccarino <brunociccarinoo@gmail.com>
#
# Theme inspired by:
#  - Bash_it cupcake theme
# Demo:
# ╭─🌙 virtualenv 🌙user at 🌙host in 🌙directory on (🌙branch {1} ↑1 ↓1 +1 •1 ⌀1 ✗)
# ╰λ cd ~/path/to/your-directory

if [ -z "${NEKONIGHT_BASE_LOADED}" ]; then
  source "$OSH/themes/nekonight/nekonight-base.sh"
  export NEKONIGHT_BASE_LOADED=true
fi

icon_start="╭─"
icon_user=" 🌙 ${_omb_prompt_bold_olive}\u${_omb_prompt_normal}"
icon_host=" at 🌙 ${_omb_prompt_bold_cyan}\h${_omb_prompt_normal}"
icon_directory=" in 🌙 ${_omb_prompt_bold_magenta}\w${_omb_prompt_normal}"
icon_end="╰─${_omb_prompt_bold_white}λ${_omb_prompt_normal}"

function _omb_theme_PROMPT_COMMAND() {
  local git_info=$(_omb_theme_nekonight_git_prompt_info)
  PS1="${icon_start}${icon_user}${icon_host}${icon_directory} in $(_omb_theme_nekonight_git_prompt_info)\n${icon_end} "
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND


