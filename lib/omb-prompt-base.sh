#! bash oh-my-bash.module

_omb_module_require lib:omb-deprecate
_omb_module_require lib:omb-prompt-colors

CLOCK_CHAR_THEME_PROMPT_PREFIX=''
CLOCK_CHAR_THEME_PROMPT_SUFFIX=''
CLOCK_THEME_PROMPT_PREFIX=''
CLOCK_THEME_PROMPT_SUFFIX=''

THEME_PROMPT_HOST='\H'

SCM_CHECK=${SCM_CHECK:=true}

SCM_THEME_PROMPT_DIRTY=' ✗'
SCM_THEME_PROMPT_CLEAN=' ✓'
SCM_THEME_PROMPT_PREFIX=' |'
SCM_THEME_PROMPT_SUFFIX='|'
SCM_THEME_BRANCH_PREFIX=''
SCM_THEME_TAG_PREFIX='tag:'
SCM_THEME_DETACHED_PREFIX='detached:'
SCM_THEME_BRANCH_TRACK_PREFIX=' → '
SCM_THEME_BRANCH_GONE_PREFIX=' ⇢ '
SCM_THEME_CURRENT_USER_PREFFIX=' ☺︎ '
SCM_THEME_CURRENT_USER_SUFFIX=''
SCM_THEME_CHAR_PREFIX=''
SCM_THEME_CHAR_SUFFIX=''

THEME_BATTERY_PERCENTAGE_CHECK=${THEME_BATTERY_PERCENTAGE_CHECK:=true}

SCM_GIT_SHOW_DETAILS=${SCM_GIT_SHOW_DETAILS:=true}
SCM_GIT_SHOW_REMOTE_INFO=${SCM_GIT_SHOW_REMOTE_INFO:=auto}
SCM_GIT_DISABLE_UNTRACKED_DIRTY=${SCM_GIT_DISABLE_UNTRACKED_DIRTY:=false}
SCM_GIT_IGNORE_UNTRACKED=${SCM_GIT_IGNORE_UNTRACKED:=false}
SCM_GIT_SHOW_CURRENT_USER=${SCM_GIT_SHOW_CURRENT_USER:=false}
SCM_GIT_SHOW_MINIMAL_INFO=${SCM_GIT_SHOW_MINIMAL_INFO:=false}

SCM_GIT='git'
SCM_GIT_CHAR='±'
SCM_GIT_DETACHED_CHAR='⌿'
SCM_GIT_AHEAD_CHAR="↑"
SCM_GIT_BEHIND_CHAR="↓"
SCM_GIT_UNTRACKED_CHAR="?:"
SCM_GIT_UNSTAGED_CHAR="U:"
SCM_GIT_STAGED_CHAR="S:"

SCM_HG='hg'
SCM_HG_CHAR='☿'

SCM_SVN='svn'
SCM_SVN_CHAR='⑆'

SCM_NONE='NONE'
SCM_NONE_CHAR='○'

THEME_SHOW_USER_HOST=${THEME_SHOW_USER_HOST:=false}
USER_HOST_THEME_PROMPT_PREFIX=''
USER_HOST_THEME_PROMPT_SUFFIX=''

# #new
# OMB_PROMPT_RBFU_FORMAT=' |%s|'
# OMB_PROMPT_RBENV_FORMAT=' |%s|'
# OMB_PROMPT_RVM_FORMAT=' |%s|'
# OMB_PROMPT_CHRUBY_FORMAT=' |%s|'

# deprecate
RBFU_THEME_PROMPT_PREFIX=' |'
RBFU_THEME_PROMPT_SUFFIX='|'
RBENV_THEME_PROMPT_PREFIX=' |'
RBENV_THEME_PROMPT_SUFFIX='|'
RVM_THEME_PROMPT_PREFIX=' |'
RVM_THEME_PROMPT_SUFFIX='|'
CHRUBY_THEME_PROMPT_PREFIX=' |'
CHRUBY_THEME_PROMPT_SUFFIX='|'

# # new
# OMB_PROMPT_VIRTUALENV_FORMAT=' |%s|'
# OMB_PROMPT_CONDAENV_FORMAT=' |%s|'
# OMB_PROMPT_CONDAENV_USE_BASENAME=true
# OMB_PROMPT_PYTHON_VERSION_FORMAT=' |%s|'
# OMB_PROMPT_SHOW_PYTHON_VENV=true

# deprecate
VIRTUALENV_THEME_PROMPT_PREFIX=' |'
VIRTUALENV_THEME_PROMPT_SUFFIX='|'
CONDAENV_THEME_PROMPT_PREFIX=' |'
CONDAENV_THEME_PROMPT_SUFFIX='|'
PYTHON_THEME_PROMPT_PREFIX=' |'
PYTHON_THEME_PROMPT_SUFFIX='|'

## @fn _omb_prompt_format var value fmt_prefix[:deprecated]
##   @param[in] var
##   @param[in] value
##   @param[in] fmt_prefix
##   @param[in,opt] deprecated
##   @var[out] $var
function _omb_prompt_format {
  local __format=${3%%:*}_FORMAT; __format=${!__format-}
  if [[ ! $__format ]]; then
    local __prefix=${3#*:}_PREFIX; __prefix=${!__prefix-} # deprecate name
    local __suffix=${3#*:}_SUFFIX; __suffix=${!__suffix-} # deprecate name
    __format=${__prefix//'%'/'%%'}%s${__suffix//'%'/'%%'}
  fi
  printf -v "$1" "$__format" "$2"
}

function _omb_prompt_git {
  command git "$@"
}

function _omb_prompt_git_status_enabled {
  [[ $(_omb_prompt_git config --get-regexp '^(oh-my-zsh|bash-it|oh-my-bash)\.hide-status$' |
    awk '$2== "1" {hide_status = 1;} END { print hide_status; }') != "1" ]]
}

function scm {
  if [[ "$SCM_CHECK" = false ]]; then SCM=$SCM_NONE
  elif [[ -f .git/HEAD ]]; then SCM=$SCM_GIT
  elif _omb_util_binary_exists git && [[ -n "$(_omb_prompt_git rev-parse --is-inside-work-tree 2> /dev/null)" ]]; then SCM=$SCM_GIT
  elif [[ -d .hg ]]; then SCM=$SCM_HG
  elif _omb_util_binary_exists hg && [[ -n "$(command hg root 2> /dev/null)" ]]; then SCM=$SCM_HG
  elif [[ -d .svn ]]; then SCM=$SCM_SVN
  else SCM=$SCM_NONE
  fi
}

function scm_prompt_char {
  if [[ -z $SCM ]]; then scm; fi
  if [[ $SCM == $SCM_GIT ]]; then SCM_CHAR=$SCM_GIT_CHAR
  elif [[ $SCM == $SCM_HG ]]; then SCM_CHAR=$SCM_HG_CHAR
  elif [[ $SCM == $SCM_SVN ]]; then SCM_CHAR=$SCM_SVN_CHAR
  else SCM_CHAR=$SCM_NONE_CHAR
  fi
}

function scm_prompt_vars {
  scm
  scm_prompt_char
  SCM_DIRTY=0
  SCM_STATE=''
  [[ $SCM == $SCM_GIT ]] && git_prompt_vars && return
  [[ $SCM == $SCM_HG ]] && hg_prompt_vars && return
  [[ $SCM == $SCM_SVN ]] && svn_prompt_vars && return
}

function scm_prompt_info {
  scm
  scm_prompt_char
  scm_prompt_info_common
}

function scm_prompt_char_info {
  scm_prompt_char
  echo -ne "${SCM_THEME_CHAR_PREFIX}${SCM_CHAR}${SCM_THEME_CHAR_SUFFIX}"
  scm_prompt_info_common
}

function scm_prompt_info_common {
  SCM_DIRTY=0
  SCM_STATE=''

  if [[ ${SCM} == ${SCM_GIT} ]]; then
    if [[ ${SCM_GIT_SHOW_MINIMAL_INFO} == true ]]; then
      # user requests minimal git status information
      git_prompt_minimal_info
    else
      # more detailed git status
      git_prompt_info
    fi
    return
  fi

  # TODO: consider adding minimal status information for hg and svn
  [[ ${SCM} == ${SCM_HG} ]] && hg_prompt_info && return
  [[ ${SCM} == ${SCM_SVN} ]] && svn_prompt_info && return
}

# This is added to address bash shell interpolation vulnerability described
# here: https://github.com/njhartwell/pw3nage
function git_clean_branch {
  local unsafe_ref=$(_omb_prompt_git symbolic-ref -q HEAD 2> /dev/null)
  local stripped_ref=${unsafe_ref##refs/heads/}
  local clean_ref=${stripped_ref//[\$\`\\]/-}
  clean_ref=${clean_ref//[^[:print:]]/-} # strip escape sequences, etc.
  echo $clean_ref
}

function git_prompt_minimal_info {
  local ref
  local status
  local git_status_flags=('--porcelain')
  SCM_STATE=${SCM_THEME_PROMPT_CLEAN}

  if _omb_prompt_git_status_enabled; then
    # Get the branch reference
    ref=$(git_clean_branch) || \
    ref=$(_omb_prompt_git rev-parse --short HEAD 2> /dev/null) || return 0
    SCM_BRANCH=${SCM_THEME_BRANCH_PREFIX}${ref}

    # Get the status
    [[ "${SCM_GIT_IGNORE_UNTRACKED}" = "true" ]] && git_status_flags+='-untracked-files=no'
    status=$(_omb_prompt_git status ${git_status_flags} 2> /dev/null | tail -n1)

    if [[ -n ${status} ]]; then
      SCM_DIRTY=1
      SCM_STATE=${SCM_THEME_PROMPT_DIRTY}
    fi

    # Output the git prompt
    SCM_PREFIX=${SCM_THEME_PROMPT_PREFIX}
    SCM_SUFFIX=${SCM_THEME_PROMPT_SUFFIX}
    echo -e "${SCM_PREFIX}${SCM_BRANCH}${SCM_STATE}${SCM_SUFFIX}"
  fi
}

function git_status_summary {
  awk '
  BEGIN {
    untracked=0;
    unstaged=0;
    staged=0;
  }
  {
    if (!after_first && $0 ~ /^##.+/) {
      print $0
      seen_header = 1
    } else if ($0 ~ /^\?\? .+/) {
      untracked += 1
    } else {
      if ($0 ~ /^.[^ ] .+/) {
        unstaged += 1
      }
      if ($0 ~ /^[^ ]. .+/) {
        staged += 1
      }
    }
    after_first = 1
  }
  END {
    if (!seen_header) {
      print
    }
    print untracked "\t" unstaged "\t" staged
  }'
}

function git_prompt_vars {
  local details=''
  local git_status_flags=''
  [[ "$(_omb_prompt_git rev-parse --is-inside-work-tree 2> /dev/null)" == "true" ]] || return 1
  SCM_STATE=${GIT_THEME_PROMPT_CLEAN:-$SCM_THEME_PROMPT_CLEAN}
  if _omb_prompt_git_status_enabled; then
    [[ "${SCM_GIT_IGNORE_UNTRACKED}" = "true" ]] && git_status_flags='-uno'
    local status_lines=$((_omb_prompt_git status --porcelain ${git_status_flags} -b 2> /dev/null ||
                          _omb_prompt_git status --porcelain ${git_status_flags}    2> /dev/null) | git_status_summary)
    local status=$(awk 'NR==1' <<< "$status_lines")
    local counts=$(awk 'NR==2' <<< "$status_lines")
    IFS=$'\t' read -r untracked_count unstaged_count staged_count <<< "$counts"
    if [[ "${untracked_count}" -gt 0 || "${unstaged_count}" -gt 0 || "${staged_count}" -gt 0 ]]; then
      if [[ "${SCM_GIT_SHOW_DETAILS}" = "true" ]]; then
        [[ "${staged_count}" -gt 0 ]] && details+=" ${SCM_GIT_STAGED_CHAR}${staged_count}" && SCM_DIRTY=3
        [[ "${unstaged_count}" -gt 0 ]] && details+=" ${SCM_GIT_UNSTAGED_CHAR}${unstaged_count}" && SCM_DIRTY=2
        [[ "${untracked_count}" -gt 0 ]] && details+=" ${SCM_GIT_UNTRACKED_CHAR}${untracked_count}" &&
          [[ "$SCM_GIT_DISABLE_UNTRACKED_DIRTY" != "true" ]] && SCM_DIRTY=1
      fi
      [[ "$SCM_GIT_DISABLE_UNTRACKED_DIRTY" != "true" || "${unstaged_count}" -gt 0 || "${staged_count}" -gt 0 ]] &&
        SCM_STATE=${GIT_THEME_PROMPT_DIRTY:-$SCM_THEME_PROMPT_DIRTY}
    fi
  fi

  [[ "${SCM_GIT_SHOW_CURRENT_USER}" == "true" ]] && details+="$(git_user_info)"

  SCM_CHANGE=$(_omb_prompt_git rev-parse --short HEAD 2>/dev/null)

  local ref=$(git_clean_branch)

  if [[ -n "$ref" ]]; then
    SCM_BRANCH="${SCM_THEME_BRANCH_PREFIX}${ref}"
    local tracking_info="$(grep -- "${SCM_BRANCH}\.\.\." <<< "${status}")"
    if [[ -n "${tracking_info}" ]]; then
      [[ "${tracking_info}" =~ .+\[gone\]$ ]] && local branch_gone="true"
      tracking_info=${tracking_info#\#\# ${SCM_BRANCH}...}
      tracking_info=${tracking_info% [*}
      local remote_name=${tracking_info%%/*}
      local remote_branch=${tracking_info#${remote_name}/}
      local remote_info=""
      local num_remotes=$(_omb_prompt_git remote | wc -l 2> /dev/null)
      [[ "${SCM_BRANCH}" = "${remote_branch}" ]] && local same_branch_name=true
      if ([[ "${SCM_GIT_SHOW_REMOTE_INFO}" = "auto" ]] && [[ "${num_remotes}" -ge 2 ]]) ||
          [[ "${SCM_GIT_SHOW_REMOTE_INFO}" = "true" ]]; then
        remote_info="${remote_name}"
        [[ "${same_branch_name}" != "true" ]] && remote_info+="/${remote_branch}"
      elif [[ ${same_branch_name} != "true" ]]; then
        remote_info="${remote_branch}"
      fi
      if [[ -n "${remote_info}" ]];then
        if [[ "${branch_gone}" = "true" ]]; then
          SCM_BRANCH+="${SCM_THEME_BRANCH_GONE_PREFIX}${remote_info}"
        else
          SCM_BRANCH+="${SCM_THEME_BRANCH_TRACK_PREFIX}${remote_info}"
        fi
      fi
    fi
    SCM_GIT_DETACHED="false"
  else
    local detached_prefix=""
    ref=$(_omb_prompt_git describe --tags --exact-match 2> /dev/null)
    if [[ -n "$ref" ]]; then
      detached_prefix=${SCM_THEME_TAG_PREFIX}
    else
      ref=$(_omb_prompt_git describe --contains --all HEAD 2> /dev/null)
      ref=${ref#remotes/}
      [[ -z "$ref" ]] && ref=${SCM_CHANGE}
      detached_prefix=${SCM_THEME_DETACHED_PREFIX}
    fi
    SCM_BRANCH=${detached_prefix}${ref}
    SCM_GIT_DETACHED="true"
  fi

  local ahead_re='.+ahead ([0-9]+).+'
  local behind_re='.+behind ([0-9]+).+'
  [[ "${status}" =~ ${ahead_re} ]] && SCM_BRANCH+=" ${SCM_GIT_AHEAD_CHAR}${BASH_REMATCH[1]}"
  [[ "${status}" =~ ${behind_re} ]] && SCM_BRANCH+=" ${SCM_GIT_BEHIND_CHAR}${BASH_REMATCH[1]}"

  local stash_count="$(_omb_prompt_git stash list 2> /dev/null | wc -l | tr -d ' ')"
  [[ "${stash_count}" -gt 0 ]] && SCM_BRANCH+=" {${stash_count}}"

  SCM_BRANCH+=${details}

  SCM_PREFIX=${GIT_THEME_PROMPT_PREFIX:-$SCM_THEME_PROMPT_PREFIX}
  SCM_SUFFIX=${GIT_THEME_PROMPT_SUFFIX:-$SCM_THEME_PROMPT_SUFFIX}
}

function svn_prompt_vars {
  if [[ -n $(command svn status 2> /dev/null) ]]; then
    SCM_DIRTY=1
    SCM_STATE=${SVN_THEME_PROMPT_DIRTY:-$SCM_THEME_PROMPT_DIRTY}
  else
    SCM_DIRTY=0
    SCM_STATE=${SVN_THEME_PROMPT_CLEAN:-$SCM_THEME_PROMPT_CLEAN}
  fi
  SCM_PREFIX=${SVN_THEME_PROMPT_PREFIX:-$SCM_THEME_PROMPT_PREFIX}
  SCM_SUFFIX=${SVN_THEME_PROMPT_SUFFIX:-$SCM_THEME_PROMPT_SUFFIX}
  SCM_BRANCH=$(command svn info 2> /dev/null | awk -F/ '/^URL:/ { for (i=0; i<=NF; i++) { if ($i == "branches" || $i == "tags" ) { print $(i+1); break }; if ($i == "trunk") { print $i; break } } }') || return
  SCM_CHANGE=$(command svn info 2> /dev/null | sed -ne 's#^Revision: ##p' )
}

# this functions returns absolute location of .hg directory if one exists
# It starts in the current directory and moves its way up until it hits /.
# If we get to / then no Mercurial repository was found.
# Example:
# - lets say we cd into ~/Projects/Foo/Bar
# - .hg is located in ~/Projects/Foo/.hg
# - get_hg_root starts at ~/Projects/Foo/Bar and sees that there is no .hg directory, so then it goes into ~/Projects/Foo
function get_hg_root {
    local CURRENT_DIR=$PWD

    while [ "$CURRENT_DIR" != "/" ]; do
        if [ -d "$CURRENT_DIR/.hg" ]; then
            echo "$CURRENT_DIR/.hg"
            return
        fi

        CURRENT_DIR=$(dirname "$CURRENT_DIR")
    done
}

function hg_prompt_vars {
    if [[ -n $(command hg status 2> /dev/null) ]]; then
      SCM_DIRTY=1
        SCM_STATE=${HG_THEME_PROMPT_DIRTY:-$SCM_THEME_PROMPT_DIRTY}
    else
      SCM_DIRTY=0
        SCM_STATE=${HG_THEME_PROMPT_CLEAN:-$SCM_THEME_PROMPT_CLEAN}
    fi
    SCM_PREFIX=${HG_THEME_PROMPT_PREFIX:-$SCM_THEME_PROMPT_PREFIX}
    SCM_SUFFIX=${HG_THEME_PROMPT_SUFFIX:-$SCM_THEME_PROMPT_SUFFIX}

    HG_ROOT=$(get_hg_root)

    if [ -f "$HG_ROOT/branch" ]; then
        # Mercurial holds it's current branch in .hg/branch file
        SCM_BRANCH=$(cat "$HG_ROOT/branch")
    else
        SCM_BRANCH=$(command hg summary 2> /dev/null | grep branch: | awk '{print $2}')
    fi

    if [ -f "$HG_ROOT/dirstate" ]; then
        # Mercurial holds various information about the working directory in .hg/dirstate file. More on http://mercurial.selenic.com/wiki/DirState
        SCM_CHANGE=$(hexdump -n 10 -e '1/1 "%02x"' "$HG_ROOT/dirstate" | cut -c-12)
    else
        SCM_CHANGE=$(command hg summary 2> /dev/null | grep parent: | awk '{print $2}')
    fi
}

function _omb_prompt_get_rbfu {
  rbfu=$RBFU_RUBY_VERSION
  [[ $rbfu ]] || return 1
  _omb_prompt_format rbfu "$rbfu" OMB_PROMPT_RBFU:RBFU_THEME_PROMPT
}

function _omb_prompt_get_rbenv {
  rbenv=
  _omb_util_command_exists rbenv || return 1

  rbenv=$(rbenv version-name)
  rbenv commands | command grep -q gemset &&
    gemset=$(rbenv gemset active 2> /dev/null) &&
    rbenv="$rbenv@${gemset%% *}"

  [[ $rbenv != system ]] || return 1
  _omb_prompt_format rbenv "$rbenv" OMB_PROMPT_RBENV:RBENV_THEME_PROMPT
}

function _omb_prompt_get_rvm {
  rvm=
  if _omb_util_command_exists rvm-prompt; then
    rvm=$(rvm-prompt)
  elif _omb_util_command_exists rvm; then
    local rvm_current=$(rvm tools identifier)
    local rvm_default=$(rvm strings default)
    [[ $rvm_current && $rvm_default && $rvm_current != "$rvm_default" ]] || return 1
    rvm=$rvm_current
  fi

  [[ $rvm ]] || return 1
  _omb_prompt_format rvm "$rvm" OMB_PROMPT_RVM:RVM_THEME_PROMPT
}

function _omb_prompt_get_chruby {
  chruby=
  _omb_util_function_exists chruby || return 1

  _omb_util_function_exists chruby_auto && chruby=$(chruby_auto)

  local ruby_version
  ruby_version=$(ruby --version | command awk '{print $1, $2;}') || return
  chruby | command grep -q '\*' || ruby_version="${ruby_version} (system)"
  _omb_prompt_format ruby_version "$ruby_version" OMB_PROMPT_CHRUBY:CHRUBY_THEME_PROMPT

  chruby+=$ruby_version
}

function _omb_prompt_get_ruby_env {
  local rbfu rbenv rvm chruby
  _omb_prompt_get_rbfu
  _omb_prompt_get_rbenv
  _omb_prompt_get_rvm
  _omb_prompt_get_chruby
  ruby_env=$rbfu$rbenv$rvm$chruby
  [[ $ruby_env ]]
}

_omb_util_defun_print _omb_prompt_{print,get}_rbfu rbfu
_omb_util_defun_print _omb_prompt_{print,get}_rbenv rbenv
_omb_util_defun_print _omb_prompt_{print,get}_rvm rvm
_omb_util_defun_print _omb_prompt_{print,get}_chruby chruby
_omb_util_defun_print _omb_prompt_{print,get}_ruby_env ruby_env

_omb_deprecate_function 20000 rbfu_version_prompt   _omb_prompt_print_rbfu
_omb_deprecate_function 20000 rbenv_version_prompt  _omb_prompt_print_rbenv
_omb_deprecate_function 20000 rvm_version_prompt    _omb_prompt_print_rvm
_omb_deprecate_function 20000 chruby_version_prompt _omb_prompt_print_chruby
_omb_deprecate_function 20000 ruby_version_prompt   _omb_prompt_print_ruby_env

function _omb_prompt_get_virtualenv {
  virtualenv=
  [[ ${VIRTUAL_ENV-} ]] || return 1
  _omb_prompt_format virtualenv "$(basename "$VIRTUAL_ENV")" OMB_PROMPT_VIRTUALENV:VIRTUALENV_THEME_PROMPT
}

function _omb_prompt_get_condaenv {
  condaenv=
  [[ ${CONDA_DEFAULT_ENV-} && ${CONDA_SHLVL-} != 0 ]] || return 1

  condaenv=$CONDA_DEFAULT_ENV
  if [[ ${OMB_PROMPT_CONDAENV_USE_BASENAME-} == true ]]; then
    condaenv=$(basename "$condaenv")
  fi
  _omb_prompt_format condaenv "$condaenv" OMB_PROMPT_CONDAENV:CONDAENV_THEME_PROMPT
}

function _omb_prompt_get_python_version {
  python_version=$(python --version 2>&1 | command awk '{print "py-"$2;}')
  [[ $python_version ]] || return 1
  _omb_prompt_format python_version "$python_version" OMB_PROMPT_PYTHON_VERSION:PYTHON_THEME_PROMPT
}

function _omb_prompt_get_python_venv {
  python_venv=
  [[ ${OMB_PROMPT_SHOW_PYTHON_VENV-} == true ]] || return 1
  local virtualenv condaenv
  _omb_prompt_get_virtualenv
  _omb_prompt_get_condaenv
  python_venv=$virtualenv$condaenv
  [[ $python_venv ]]
}
function _omb_prompt_get_python_env {
  local virtualenv condaenv python_version
  _omb_prompt_get_virtualenv
  _omb_prompt_get_condaenv
  _omb_prompt_get_python_version
  python_env=$virtualenv$condaenv$python_version
  [[ $python_env ]]
}

_omb_util_defun_print _omb_prompt_{print,get}_virtualenv virtualenv
_omb_util_defun_print _omb_prompt_{print,get}_condaenv condaenv
_omb_util_defun_print _omb_prompt_{print,get}_python_version python_version
_omb_util_defun_print _omb_prompt_{print,get}_python_venv python_venv
_omb_util_defun_print _omb_prompt_{print,get}_python_env python_env

_omb_deprecate_function 20000 virtualenv_prompt     _omb_prompt_print_virtualenv
_omb_deprecate_function 20000 condaenv_prompt       _omb_prompt_print_condaenv
_omb_deprecate_function 20000 py_interp_prompt      _omb_prompt_print_python_version
_omb_deprecate_function 20000 python_version_prompt _omb_prompt_print_python_env

function git_user_info {
  # support two or more initials, set by 'git pair' plugin
  SCM_CURRENT_USER=$(_omb_prompt_git config user.initials | sed 's% %+%')
  # if `user.initials` weren't set, attempt to extract initials from `user.name`
  [[ -z "${SCM_CURRENT_USER}" ]] && SCM_CURRENT_USER=$(printf "%s" $(for word in $(_omb_prompt_git config user.name | tr 'A-Z' 'a-z'); do printf "%1.1s" $word; done))
  [[ -n "${SCM_CURRENT_USER}" ]] && printf "%s" "$SCM_THEME_CURRENT_USER_PREFFIX$SCM_CURRENT_USER$SCM_THEME_CURRENT_USER_SUFFIX"
}

function clock_char {
  CLOCK_CHAR=${THEME_CLOCK_CHAR:-"⌚"}
  CLOCK_CHAR_COLOR=${THEME_CLOCK_CHAR_COLOR:-"$_omb_prompt_normal"}
  SHOW_CLOCK_CHAR=${THEME_SHOW_CLOCK_CHAR:-"true"}

  if [[ "${SHOW_CLOCK_CHAR}" = "true" ]]; then
    echo -e "${CLOCK_CHAR_COLOR}${CLOCK_CHAR_THEME_PROMPT_PREFIX}${CLOCK_CHAR}${CLOCK_CHAR_THEME_PROMPT_SUFFIX}"
  fi
}

function clock_prompt {
  CLOCK_COLOR=${THEME_CLOCK_COLOR:-"$_omb_prompt_normal"}
  CLOCK_FORMAT=${THEME_CLOCK_FORMAT:-"%H:%M:%S"}
  [ -z $THEME_SHOW_CLOCK ] && THEME_SHOW_CLOCK=${THEME_CLOCK_CHECK:-"true"}
  SHOW_CLOCK=$THEME_SHOW_CLOCK

  if [[ "${SHOW_CLOCK}" = "true" ]]; then
    CLOCK_STRING=$(date +"${CLOCK_FORMAT}")
    echo -e "${CLOCK_COLOR}${CLOCK_THEME_PROMPT_PREFIX}${CLOCK_STRING}${CLOCK_THEME_PROMPT_SUFFIX}"
  fi
}

function user_host_prompt {
  if [[ "${THEME_SHOW_USER_HOST}" = "true" ]]; then
      echo -e "${USER_HOST_THEME_PROMPT_PREFIX}\u@\h${USER_HOST_THEME_PROMPT_SUFFIX}"
  fi
}

# backwards-compatibility
function git_prompt_info {
  git_prompt_vars
  echo -e "${SCM_PREFIX}${SCM_BRANCH}${SCM_STATE}${SCM_SUFFIX}"
}

function svn_prompt_info {
  svn_prompt_vars
  echo -e "${SCM_PREFIX}${SCM_BRANCH}${SCM_STATE}${SCM_SUFFIX}"
}

function hg_prompt_info() {
  hg_prompt_vars
  echo -e "${SCM_PREFIX}${SCM_BRANCH}:${SCM_CHANGE#*:}${SCM_STATE}${SCM_SUFFIX}"
}

function scm_char {
  scm_prompt_char
  echo -e "${SCM_THEME_CHAR_PREFIX}${SCM_CHAR}${SCM_THEME_CHAR_SUFFIX}"
}

function prompt_char {
    scm_char
}

function battery_char {
    if [[ "${THEME_BATTERY_PERCENTAGE_CHECK}" = true ]]; then
        echo -e "${_omb_prompt_bold_brown}$(battery_percentage)%"
    fi
}

if ! _omb_util_command_exists 'battery_charge' ; then
    # if user has installed battery plugin, skip this...
    function battery_charge (){
        # no op
        echo -n
    }
fi

# The battery_char function depends on the presence of the battery_percentage function.
# If battery_percentage is not defined, then define battery_char as a no-op.
if ! _omb_util_command_exists 'battery_percentage' ; then
    function battery_char (){
      # no op
      echo -n
    }
fi

function aws_profile {
  if [[ $AWS_DEFAULT_PROFILE ]]; then
    echo -e "${AWS_DEFAULT_PROFILE}"
  else
    echo -e "default"
  fi
}


# Returns true if $1 is a shell function.
_omb_deprecate_function 20000 fn_exists _omb_util_function_exists
_omb_deprecate_function 20000 safe_append_prompt_command _omb_util_add_prompt_command
