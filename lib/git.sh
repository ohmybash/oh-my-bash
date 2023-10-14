#! bash oh-my-bash.module
# Outputs current branch info in prompt format

_omb_module_require lib:omb-prompt-colors
_omb_module_require lib:omb-prompt-base
_omb_module_require lib:omb-deprecate

: "${_omb_git_post_1_7_2:=${POST_1_7_2_GIT:-}}"
_omb_deprecate_declare 20000 POST_1_7_2_GIT _omb_git_post_1_7_2 sync

# # Note: The same name of a functionis defined in omb-prompt-base.  We comment
# # out this function for now.
# function git_prompt_info {
#   local ref
#   if [[ $(_omb_prompt_git config --get oh-my-bash.hide-status 2>/dev/null) != 1 ]]; then
#     ref=$(_omb_prompt_git symbolic-ref HEAD 2> /dev/null) || \
#     ref=$(_omb_prompt_git rev-parse --short HEAD 2> /dev/null) || return 0
#     echo "$OSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$(parse_git_dirty)$OSH_THEME_GIT_PROMPT_SUFFIX"
#   fi
# }

# Checks if working tree is dirty
function parse_git_dirty {
  local STATUS=
  local -a FLAGS=('--porcelain')
  if [[ $(_omb_prompt_git config --get oh-my-bash.hide-dirty) != 1 ]]; then
    if ((${_omb_git_post_1_7_2:=$(git_compare_version "1.7.2")} > 0)); then
      FLAGS+=('--ignore-submodules=dirty')
    fi
    if [[ $DISABLE_UNTRACKED_FILES_DIRTY == "true" ]]; then
      FLAGS+=('--untracked-files=no')
    fi
    STATUS=$(_omb_prompt_git status "${FLAGS[@]}" 2> /dev/null | tail -n1)
  fi
  if [[ $STATUS ]]; then
    echo "$OSH_THEME_GIT_PROMPT_DIRTY"
  else
    echo "$OSH_THEME_GIT_PROMPT_CLEAN"
  fi
}

# Gets the difference between the local and remote branches
function git_remote_status {
  local git_remote_origin=$(_omb_prompt_git rev-parse --verify ${hook_com[branch]}@{upstream} --symbolic-full-name 2>/dev/null)
  local remote=${git_remote_origin/refs\/remotes\//}
  if [[ $remote ]]; then
    local ahead=$(_omb_prompt_git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | wc -l)
    local behind=$(_omb_prompt_git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | wc -l)

    local git_remote_status git_remote_status_detailed
    if ((ahead == 0 && behind == 0)); then
      git_remote_status=$OSH_THEME_GIT_PROMPT_EQUAL_REMOTE
    elif ((ahead > 0 && behind == 0)); then
      git_remote_status=$OSH_THEME_GIT_PROMPT_AHEAD_REMOTE
      git_remote_status_detailed=$OSH_THEME_GIT_PROMPT_AHEAD_REMOTE_COLOR$OSH_THEME_GIT_PROMPT_AHEAD_REMOTE$((ahead))$_omb_prompt_reset_color
    elif ((behind > 0 && ahead == 0)); then
      git_remote_status=$OSH_THEME_GIT_PROMPT_BEHIND_REMOTE
      git_remote_status_detailed=$OSH_THEME_GIT_PROMPT_BEHIND_REMOTE_COLOR$OSH_THEME_GIT_PROMPT_BEHIND_REMOTE$((behind))$_omb_prompt_reset_color
    elif ((ahead > 0 && behind > 0)); then
      git_remote_status=$OSH_THEME_GIT_PROMPT_DIVERGED_REMOTE
      git_remote_status_detailed=$OSH_THEME_GIT_PROMPT_AHEAD_REMOTE_COLOR$OSH_THEME_GIT_PROMPT_AHEAD_REMOTE$((ahead))$_omb_prompt_reset_color$OSH_THEME_GIT_PROMPT_BEHIND_REMOTE_COLOR$OSH_THEME_GIT_PROMPT_BEHIND_REMOTE$((behind))$_omb_prompt_reset_color
    fi

    if [[ $OSH_THEME_GIT_PROMPT_REMOTE_STATUS_DETAILED ]]; then
      git_remote_status=$OSH_THEME_GIT_PROMPT_REMOTE_STATUS_PREFIX$remote$git_remote_status_detailed$OSH_THEME_GIT_PROMPT_REMOTE_STATUS_SUFFIX
    fi

    echo "$git_remote_status"
  fi
}

# Outputs the name of the current branch
# Usage example: git pull origin $(git_current_branch)
# Using '--quiet' with 'symbolic-ref' will not cause a fatal error (128) if
# it's not a symbolic ref, but in a Git repo.
function git_current_branch {
  local ref
  ref=$(_omb_prompt_git symbolic-ref --quiet HEAD 2> /dev/null)
  local ret=$?
  if [[ $ret != 0 ]]; then
    [[ $ret == 128 ]] && return  # no git repo.
    ref=$(_omb_prompt_git rev-parse --short HEAD 2> /dev/null) || return
  fi
  echo ${ref#refs/heads/}
}


# Gets the number of commits ahead from remote
function git_commits_ahead {
  if _omb_prompt_git rev-parse --git-dir &>/dev/null; then
    local commits=$(_omb_prompt_git rev-list --count @{upstream}..HEAD)
    if ((commits != 0)); then
      echo "$OSH_THEME_GIT_COMMITS_AHEAD_PREFIX$commits$OSH_THEME_GIT_COMMITS_AHEAD_SUFFIX"
    fi
  fi
}

# Gets the number of commits behind remote
function git_commits_behind {
  if _omb_prompt_git rev-parse --git-dir &>/dev/null; then
    local commits=$(_omb_prompt_git rev-list --count HEAD..@{upstream})
    if ((commits != 0)); then
      echo "$OSH_THEME_GIT_COMMITS_BEHIND_PREFIX$commits$OSH_THEME_GIT_COMMITS_BEHIND_SUFFIX"
    fi
  fi
}

# Outputs if current branch is ahead of remote
function git_prompt_ahead {
  if [[ $(_omb_prompt_git rev-list origin/$(git_current_branch)..HEAD 2> /dev/null) ]]; then
    echo "$OSH_THEME_GIT_PROMPT_AHEAD"
  fi
}

# Outputs if current branch is behind remote
function git_prompt_behind {
  if [[ $(_omb_prompt_git rev-list HEAD..origin/$(git_current_branch) 2> /dev/null) ]]; then
    echo "$OSH_THEME_GIT_PROMPT_BEHIND"
  fi
}

# Outputs if current branch exists on remote or not
function git_prompt_remote {
  if [[ $(_omb_prompt_git show-ref origin/$(git_current_branch) 2> /dev/null) ]]; then
    echo "$OSH_THEME_GIT_PROMPT_REMOTE_EXISTS"
  else
    echo "$OSH_THEME_GIT_PROMPT_REMOTE_MISSING"
  fi
}

# Formats prompt string for current git commit short SHA
function git_prompt_short_sha {
  local SHA
  SHA=$(_omb_prompt_git rev-parse --short HEAD 2> /dev/null) &&
    echo "$OSH_THEME_GIT_PROMPT_SHA_BEFORE$SHA$OSH_THEME_GIT_PROMPT_SHA_AFTER"
}

# Formats prompt string for current git commit long SHA
function git_prompt_long_sha {
  local SHA
  SHA=$(_omb_prompt_git rev-parse HEAD 2> /dev/null) &&
    echo "$OSH_THEME_GIT_PROMPT_SHA_BEFORE$SHA$OSH_THEME_GIT_PROMPT_SHA_AFTER"
}

# Get the status of the working tree
function git_prompt_status {
  local INDEX=$(_omb_prompt_git status --porcelain -b 2> /dev/null)
  local STATUS=
  if command grep -qE '^\?\? ' <<< "$INDEX"; then
    STATUS=$OSH_THEME_GIT_PROMPT_UNTRACKED$STATUS
  fi
  if command grep -q '^[AM]  ' <<< "$INDEX"; then
    STATUS=$OSH_THEME_GIT_PROMPT_ADDED$STATUS
  fi
  if command grep -qE '^[ A]M |^ T ' <<< "$INDEX"; then
    STATUS=$OSH_THEME_GIT_PROMPT_MODIFIED$STATUS
  fi
  if command grep -q '^R  ' <<< "$INDEX"; then
    STATUS=$OSH_THEME_GIT_PROMPT_RENAMED$STATUS
  fi
  if command grep -qE '^[ A]D |D  ' <<< "$INDEX"; then
    STATUS=$OSH_THEME_GIT_PROMPT_DELETED$STATUS
  fi
  if _omb_prompt_git rev-parse --verify refs/stash &> /dev/null; then
    STATUS=$OSH_THEME_GIT_PROMPT_STASHED$STATUS
  fi
  if command grep -q '^UU ' <<< "$INDEX"; then
    STATUS=$OSH_THEME_GIT_PROMPT_UNMERGED$STATUS
  fi
  if command grep -q '^## [^ ]\+ .*ahead' <<< "$INDEX"; then
    STATUS=$OSH_THEME_GIT_PROMPT_AHEAD$STATUS
  fi
  if command grep -q '^## [^ ]\+ .*behind' <<< "$INDEX"; then
    STATUS=$OSH_THEME_GIT_PROMPT_BEHIND$STATUS
  fi
  if command grep -q '^## [^ ]\+ .*diverged' <<< "$INDEX"; then
    STATUS=$OSH_THEME_GIT_PROMPT_DIVERGED$STATUS
  fi
  echo "$STATUS"
}

# Compares the provided version of git to the version installed and on path
# Outputs -1, 0, or 1 if the installed version is less than, equal to, or
# greater than the input version, respectively.
function git_compare_version {
  local INPUT_GIT_VERSION INSTALLED_GIT_VERSION
  _omb_util_split INPUT_GIT_VERSION "$1" '.'
  _omb_util_split INSTALLED_GIT_VERSION "$(_omb_prompt_git --version 2>/dev/null)"
  _omb_util_split INSTALLED_GIT_VERSION "${INSTALLED_GIT_VERSION[2]}" '.'

  local i
  for i in {0..2}; do
    if ((INSTALLED_GIT_VERSION[i] > INPUT_GIT_VERSION[i])); then
      echo 1
      return 0
    fi
    if ((INSTALLED_GIT_VERSION[i] < INPUT_GIT_VERSION[i])); then
      echo -1
      return 0
    fi
  done
  echo 0
}

# Outputs the name of the current user
# Usage example: $(git_current_user_name)
function git_current_user_name {
  _omb_prompt_git config user.name 2>/dev/null
}

# Outputs the email of the current user
# Usage example: $(git_current_user_email)
function git_current_user_email {
  _omb_prompt_git config user.email 2>/dev/null
}
