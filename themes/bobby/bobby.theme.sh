#! bash oh-my-bash.module

SCM_THEME_PROMPT_DIRTY=" ${red}✗"
SCM_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓"
SCM_THEME_PROMPT_PREFIX=" ${green}|"
SCM_THEME_PROMPT_SUFFIX="${green}|"

GIT_THEME_PROMPT_DIRTY=" ${red}✗"
GIT_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓"
GIT_THEME_PROMPT_PREFIX=" ${green}|"
GIT_THEME_PROMPT_SUFFIX="${green}|"

RVM_THEME_PROMPT_PREFIX="|"
RVM_THEME_PROMPT_SUFFIX="|"

__bobby_clock() {
  printf "$(clock_prompt) "

  if [ "${THEME_SHOW_CLOCK_CHAR}" == "true" ]; then
    printf "$(clock_char) "
  fi
}

function _omb_theme_PROMPT_COMMAND() {
    #PS1="${_omb_prompt_bold_cyan}$(scm_char)${green}$(scm_prompt_info)${purple}$(_omb_prompt_print_ruby_env) ${yellow}\h ${_omb_prompt_reset_color}in ${green}\w ${_omb_prompt_reset_color}\n${green}→${_omb_prompt_reset_color} "
    PS1="\n$(battery_char) $(__bobby_clock)${yellow}$(_omb_prompt_print_ruby_env) ${purple}\h ${_omb_prompt_reset_color}in ${green}\w\n${_omb_prompt_bold_cyan}$(scm_prompt_char_info) ${green}→${_omb_prompt_reset_color} "
}

THEME_SHOW_CLOCK_CHAR=${THEME_SHOW_CLOCK_CHAR:-"true"}
THEME_CLOCK_CHAR_COLOR=${THEME_CLOCK_CHAR_COLOR:-"$red"}
THEME_CLOCK_COLOR=${THEME_CLOCK_COLOR:-"$_omb_prompt_bold_cyan"}
THEME_CLOCK_FORMAT=${THEME_CLOCK_FORMAT:-"%Y-%m-%d %H:%M:%S"}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
