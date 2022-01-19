#! bash oh-my-bash.module

SCM_THEME_PROMPT_DIRTY=" ${_omb_prompt_red}✗"
SCM_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓"
SCM_THEME_PROMPT_PREFIX=" |"
SCM_THEME_PROMPT_SUFFIX="${_omb_prompt_green}|"

GIT_THEME_PROMPT_DIRTY=" ${_omb_prompt_red}✗"
GIT_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓"
GIT_THEME_PROMPT_PREFIX=" ${_omb_prompt_green}|"
GIT_THEME_PROMPT_SUFFIX="${_omb_prompt_green}|"

RVM_THEME_PROMPT_PREFIX="|"
RVM_THEME_PROMPT_SUFFIX="|"

function get_hour_color {
    hour_color=$_omb_prompt_red
    min=$(date +%M)
    if [ "$min" -lt "15" ]; then
        hour_color=$_omb_prompt_white
    elif [ "$min" -lt "30" ]; then
        hour_color=$_omb_prompt_green
    elif [ "$min" -lt "45" ]; then
        hour_color=$_omb_prompt_yellow
    else
        hour_color=$_omb_prompt_red
    fi
    echo "$hour_color"
}

__emperor_clock() {
  THEME_CLOCK_COLOR=$(get_hour_color)
  clock_prompt
}

function _omb_theme_PROMPT_COMMAND() {
    PS1="\n$(__emperor_clock)${_omb_prompt_magenta}\h ${_omb_prompt_reset_color}in ${prompt_color}\w\n${_omb_prompt_bold_cyan}$(scm_char)${_omb_prompt_green}$(scm_prompt_info) ${_omb_prompt_green}→${_omb_prompt_reset_color} "
}

THEME_CLOCK_FORMAT=${THEME_CLOCK_FORMAT:-"%H "}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
