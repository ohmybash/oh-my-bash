#! bash oh-my-bash.module

SCM_THEME_PROMPT_DIRTY=" ${_omb_prompt_brown}✗"
SCM_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓"
SCM_THEME_PROMPT_PREFIX=" ${_omb_prompt_green}|"
SCM_THEME_PROMPT_SUFFIX="${_omb_prompt_green}|"

GIT_THEME_PROMPT_DIRTY=" ${_omb_prompt_brown}✗"
GIT_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓"
GIT_THEME_PROMPT_PREFIX=" ${_omb_prompt_green}|"
GIT_THEME_PROMPT_SUFFIX="${_omb_prompt_green}|"

RVM_THEME_PROMPT_PREFIX="|"
RVM_THEME_PROMPT_SUFFIX="|"

function __bobby_clock {
  printf "$(clock_prompt) "

  if [ "${THEME_SHOW_CLOCK_CHAR}" == "true" ]; then
    printf "$(clock_char) "
  fi
}

function _omb_theme_PROMPT_COMMAND() {
    #PS1="${_omb_prompt_bold_teal}$(scm_char)${_omb_prompt_green}$(scm_prompt_info)${_omb_prompt_purple}$(_omb_prompt_print_ruby_env) ${_omb_prompt_olive}\h ${_omb_prompt_reset_color}in ${_omb_prompt_green}\w ${_omb_prompt_reset_color}\n${_omb_prompt_green}→${_omb_prompt_reset_color} "
    PS1="\n$(battery_char) $(__bobby_clock)${_omb_prompt_olive}$(_omb_prompt_print_ruby_env) ${_omb_prompt_purple}\h ${_omb_prompt_reset_color}in ${_omb_prompt_green}\w\n${_omb_prompt_bold_teal}$(scm_prompt_char_info) ${_omb_prompt_green}→${_omb_prompt_reset_color} "
}

THEME_SHOW_CLOCK_CHAR=${THEME_SHOW_CLOCK_CHAR:-"true"}
THEME_CLOCK_CHAR_COLOR=${THEME_CLOCK_CHAR_COLOR:-"$_omb_prompt_brown"}
THEME_CLOCK_COLOR=${THEME_CLOCK_COLOR:-"$_omb_prompt_bold_teal"}
THEME_CLOCK_FORMAT=${THEME_CLOCK_FORMAT:-"%Y-%m-%d %H:%M:%S"}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
