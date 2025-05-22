#! bash oh-my-bash.module

_omb_deprecate_const 20000 red "$_omb_prompt_brown" "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_brown}"
_omb_deprecate_const 20000 blue "$_omb_prompt_navy" "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_navy}"
_omb_deprecate_const 20000 green "$_omb_prompt_green" "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_green}"
_omb_deprecate_const 20000 purple "$_omb_prompt_purple" "${_omb_deprecate_msg_please_use/'%s'/_omb_prompt_purple}"

SCM_GIT_SHOW_MINIMAL_INFO=true
SCM_THEME_PROMPT_PREFIX=""
SCM_THEME_PROMPT_SUFFIX=""

L_BLUE=$_omb_prompt_navy
L_CYAN=$_omb_prompt_teal
L_GREEN=$_omb_prompt_green
L_NORMAL=$_omb_prompt_normal
L_PURPLE=$_omb_prompt_purple
L_RED=$_omb_prompt_brown
L_WHITE=$_omb_prompt_white

L_BOLD_RAD=$_omb_prompt_bold_brown
L_BOLD_YELLOW=$_omb_prompt_bold_olive

L_PREFIX=$SCM_THEME_PROMPT_PREFIX
L_SUFFIX=$SCM_THEME_PROMPT_SUFFIX

# reset git_prompt_minimal_info
function git_prompt_minimal_info {
  local ref
  local status
  local git_status_flags=('--porcelain')
  SCM_STATE=${L_GREEN}${SCM_THEME_PROMPT_CLEAN}

  if _omb_prompt_git_status_enabled; then
    # Get the branch reference
    ref=$(git_clean_branch) ||
      ref=$(_omb_prompt_git rev-parse --short HEAD 2>/dev/null) || return 0
    SCM_BRANCH=${SCM_THEME_BRANCH_PREFIX}${ref}

    # Get the status
    [[ "${SCM_GIT_IGNORE_UNTRACKED}" = "true" ]] && git_status_flags+='-untracked-files=no'
    status=$(_omb_prompt_git status ${git_status_flags} 2>/dev/null | tail -n1)

    if [[ -n ${status} ]]; then
      SCM_DIRTY=1
      SCM_STATE=${L_RED}${SCM_THEME_PROMPT_DIRTY}
    fi

    # Output the git prompt
    echo -e " ${L_WHITE}on ${L_BLUE}git:${L_PURPLE}${SCM_BRANCH}${SCM_STATE}"
  fi
}

function _omb_theme_PROMPT_COMMAND() {
  local python_venv
  _omb_prompt_get_python_venv
  PS1="$python_venv${L_CYAN}\u ${L_WHITE}@ ${L_GREEN}\h ${L_WHITE}in ${L_BOLD_YELLOW}\w$(scm_prompt_info)${L_WHITE} [$(clock_prompt)]\n${L_BOLD_RAD}\$ ${L_NORMAL}"
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
