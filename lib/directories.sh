#! bash oh-my-bash.module
# Common directories functions

OMB_DIRECTORIES_CD_USE_PUSHD=false

_omb_cd_dirstack=("$PWD")

# A clone of the Zsh `cd' builtin command.  This supports the numbered option
# `-1', `-2', etc.
function _omb_directories_cd {
  local -i index
  if [[ $# -eq 1 && $1 =~ ^-[1-9]+$ ]]; then
    index=${1#-}
    if ((index >= ${#_omb_cd_dirstack[@]})); then
      builtin echo "cd: no such entry in dir stack" >&2
      return 1
    fi
    set -- "${_omb_cd_dirstack[index]}"
  fi
  if [[ ${OMB_DIRECTORIES_CD_USE_PUSHD-} == true ]]; then
    local oldpwd=$OLDPWD
    builtin pushd . >/dev/null &&
      OLDPWD=$oldpwd builtin cd "$@" &&
      oldpwd=$OLDPWD &&
      builtin pushd . >/dev/null &&
      for ((index = ${#DIRSTACK[@]} - 1; index >= 1; index--)); do
        if [[ ${DIRSTACK[0]/#~/$HOME} == "${DIRSTACK[index]}" ]]; then
          builtin popd "+$index" >/dev/null || return 1
        fi
      done
    local status=$?
    _omb_cd_dirstack=("${DIRSTACK[@]/#~/$HOME}")
    OLDPWD=$oldpwd
  else
    [[ ${_omb_cd_dirstack[0]} == "$PWD" ]] ||
      _omb_cd_dirstack=("$PWD" "${_omb_cd_dirstack[@]}")
    builtin cd "$@" &&
      _omb_cd_dirstack=("$PWD" "${_omb_cd_dirstack[@]}")
    local status=$?

    for ((index = ${#_omb_cd_dirstack[@]} - 1; index >= 1; index--)); do
      if [[ ${_omb_cd_dirstack[0]} == "${_omb_cd_dirstack[index]}" ]]; then
        unset -v '_omb_cd_dirstack[index]'
      fi
    done
    _omb_cd_dirstack=("${_omb_cd_dirstack[@]}")
  fi
  return "$status"
}
_omb_util_alias cd='_omb_directories_cd'

_omb_util_alias cd..='cd ../'                         # Go back 1 directory level (for fast typers)
_omb_util_alias ..='cd ../'                           # Go back 1 directory level
_omb_util_alias ...='cd ../../'                       # Go back 2 directory levels
_omb_util_alias .3='cd ../../../'                     # Go back 3 directory levels
_omb_util_alias .4='cd ../../../../'                  # Go back 4 directory levels
_omb_util_alias .5='cd ../../../../../'               # Go back 5 directory levels
_omb_util_alias .6='cd ../../../../../../'            # Go back 6 directory levels

_omb_util_alias -='cd -'
_omb_util_alias 1='cd -'
_omb_util_alias 2='cd -2'
_omb_util_alias 3='cd -3'
_omb_util_alias 4='cd -4'
_omb_util_alias 5='cd -5'
_omb_util_alias 6='cd -6'
_omb_util_alias 7='cd -7'
_omb_util_alias 8='cd -8'
_omb_util_alias 9='cd -9'

_omb_util_alias md='mkdir -p'
_omb_util_alias rd='rmdir'
_omb_util_alias d='dirs -v | head -10'
_omb_util_alias po='popd'

# List directory contents
_omb_util_alias lsa='ls -lha'
_omb_util_alias l='ls -lha'
_omb_util_alias ll='ls -lh'
_omb_util_alias la='ls -lhA'

# From bourne-shell.sh (unused)
#_omb_util_alias l='ls -CF'
#_omb_util_alias ll='ls -laF'
#_omb_util_alias la='ls -A'
