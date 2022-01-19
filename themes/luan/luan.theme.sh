#! bash oh-my-bash.module

SCM_THEME_PROMPT_DIRTY=" ${red}✗"
SCM_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓"
SCM_THEME_PROMPT_PREFIX="(${yellow}"
SCM_THEME_PROMPT_SUFFIX="${_omb_prompt_normal})"

GIT_THEME_PROMPT_DIRTY=" ${red}✗"
GIT_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓"
GIT_THEME_PROMPT_PREFIX="(${yellow}"
GIT_THEME_PROMPT_SUFFIX="${_omb_prompt_normal})"

RVM_THEME_PROMPT_PREFIX=""
RVM_THEME_PROMPT_SUFFIX=""

function _omb_theme_PROMPT_COMMAND() {
    dtime="$(clock_prompt)"
    user_host="${green}\u@${_omb_prompt_cyan}\h${_omb_prompt_normal}"
    current_dir="${_omb_prompt_bold_blue}\w${_omb_prompt_normal}"
    rvm_ruby="${_omb_prompt_bold_red}$(_omb_prompt_print_ruby_env)${_omb_prompt_normal}"
    git_branch="$(scm_prompt_info)${_omb_prompt_normal}"
    prompt="${_omb_prompt_bold_green}\$${_omb_prompt_normal} "
    arrow="${_omb_prompt_bold_white}▶${_omb_prompt_normal} "
    prompt="${_omb_prompt_bold_green}\$${_omb_prompt_normal} "

    PS1="${dtime}${user_host}:${current_dir} ${rvm_ruby} ${git_branch}
      $arrow $prompt"
}

THEME_CLOCK_COLOR=${THEME_CLOCK_COLOR:-"$yellow"}
THEME_CLOCK_FORMAT=${THEME_TIME_FORMAT:-"%I:%M:%S "}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
