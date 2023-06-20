#! bash oh-my-bash.module
#  ---------------------------------------------------------------------------

# A clone of the Zsh `cd' builtin command.  This supports the numbered option
# `-1', `-2', etc.
function _omb_directories_cd {
  local oldpwd=$OLDPWD
  local -i index
  if [[ $# -eq 1 && $1 =~ ^-[1-9]+$ ]]; then
    index=${1#-}
    if ((index >= ${#DIRSTACK[@]})); then
      builtin echo "cd: no such entry in dir stack" >&2
      return 1
    fi
    set -- "${DIRSTACK[index]}"
  fi
  builtin pushd . >/dev/null &&
    OLDPWD=$oldpwd builtin cd "$@" &&
    oldpwd=$OLDPWD &&
    builtin pushd . >/dev/null &&
    for ((index = ${#DIRSTACK[@]} - 1; index >= 1; index--)); do
      if [[ ${DIRSTACK[0]/#~/$HOME} == "${DIRSTACK[index]}" ]]; then
        builtin popd "+$index" >/dev/null || return 1
      fi
    done
  OLDPWD=$oldpwd
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

