#! bash oh-my-bash.module

function _omb_theme_PROMPT_COMMAND() {
    PS1="${_omb_prompt_green}\u@\h $(clock_prompt) ${_omb_prompt_reset_color}${_omb_prompt_white}\w${_omb_prompt_reset_color}$(scm_prompt_info)${_omb_prompt_blue} →${_omb_prompt_bold_blue} ${_omb_prompt_reset_color} ";
}

THEME_CLOCK_COLOR=${THEME_CLOCK_COLOR:-"$_omb_prompt_blue"}
THEME_CLOCK_FORMAT=${THEME_CLOCK_FORMAT:-"%I:%M:%S"}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
