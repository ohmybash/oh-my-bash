#! bash oh-my-bash.module
# n0qorg theme by Florian Baumann <flo@noqqe.de>

## look-a-like
# host directory (branch*)»
# for example:
# ananas ~/Code/bash-it/themes (master*)»
function _omb_theme_PROMPT_COMMAND() {
    PS1="${_omb_prompt_bold_navy}[$(hostname)]${_omb_prompt_normal} \w${_omb_prompt_normal} ${_omb_prompt_bold_white}[$(git_prompt_info)]${_omb_prompt_normal}» "
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND

## git-theme
# feel free to change git chars.
GIT_THEME_PROMPT_DIRTY="${_omb_prompt_bold_navy}*${_omb_prompt_bold_white}"
GIT_THEME_PROMPT_CLEAN=""
GIT_THEME_PROMPT_PREFIX="${_omb_prompt_bold_navy}(${_omb_prompt_bold_white}"
GIT_THEME_PROMPT_SUFFIX="${_omb_prompt_bold_navy})"

## alternate chars
SCM_THEME_PROMPT_DIRTY="*"
SCM_THEME_PROMPT_CLEAN=""
SCM_THEME_PROMPT_PREFIX="("
SCM_THEME_PROMPT_SUFFIX=")"
