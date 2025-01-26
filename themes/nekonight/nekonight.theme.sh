#! bash oh-my-bash.module
# nekonight Bash prompt with source control management
# Author: Bruno Ciccarino <brunociccarinoo@gmail.com>
#
# Theme inspired by:
#  - Bash_it cupcake theme
# Demo:
# ╭─🐱 virtualenv 🐱user at 🐱host in 🐱directory on (🐱branch {1} ↑1 ↓1 +1 •1 ⌀1 ✗)
# ╰λ cd ~/path/to/your-directory

_omb_theme_nekonight_icon_emoji="🐱"

source "$OSH/themes/nekonight/nekonight.base.sh"

function _omb_theme_PROMPT_COMMAND() {
  PS1="${icon_start}${icon_user}${icon_host}${icon_directory} in $(_omb_theme_nekonight_git_prompt_info)\n${icon_end} "
}
_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
