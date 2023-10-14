#! bash oh-my-bash.module
# ------------------------------------------------------------------#
#          FILE: cooperkid.zsh-theme                                #
#            BY: Alfredo Bejarano                                   #
#      BASED ON: Mr Briggs by Matt Brigg (matt@mattbriggs.net)      #
# ------------------------------------------------------------------#

SCM_THEME_PROMPT_DIRTY="${_omb_prompt_brown} ✗${_omb_prompt_reset_color}"
SCM_THEME_PROMPT_AHEAD="${_omb_prompt_olive} ↑${_omb_prompt_reset_color}"
SCM_THEME_PROMPT_CLEAN="${_omb_prompt_green} ✓${_omb_prompt_reset_color}"
SCM_THEME_PROMPT_PREFIX=" "
SCM_THEME_PROMPT_SUFFIX=""
GIT_SHA_PREFIX="${_omb_prompt_navy}"
GIT_SHA_SUFFIX="${_omb_prompt_reset_color}"

function git_short_sha() {
  SHA=$(_omb_prompt_git rev-parse --short HEAD 2> /dev/null) && echo "$GIT_SHA_PREFIX$SHA$GIT_SHA_SUFFIX"
}

function _omb_theme_PROMPT_COMMAND() {
    local return_status=""
    local ruby="${_omb_prompt_brown}$(_omb_prompt_print_ruby_env)${_omb_prompt_reset_color}"
    local user_host="${_omb_prompt_green}\h @ \w${_omb_prompt_reset_color}"
    local git_branch="$(git_short_sha)${_omb_prompt_teal}$(scm_prompt_info)${_omb_prompt_reset_color}"
    local prompt_symbol=' '
    local prompt_char="${_omb_prompt_purple}>_${_omb_prompt_reset_color} "

    PS1="\n${user_host}${prompt_symbol}${ruby} ${git_branch} ${return_status}\n${prompt_char}"
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
