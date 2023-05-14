#! bash oh-my-bash.module

## This module provides the following function which can be used as "readlink
## -f" that can be used in any systems.  The implementation is taken from
## "ble/util/readlink" from ble.sh <https://github.com/akinomyoga/ble.sh>.
##
## @fn _omb_util_readlink filename
##   print the real path of the filename which is possibly a symbolic link.
##

_omb_module_require lib:utils

if ((_omb_bash_version >= 40000)); then
  _omb_util_readlink_visited_init='local -A visited=()'
  function _omb_util_readlink__visited {
    [[ ${visited[$1]+set} ]] && return 0
    visited[$1]=1
    return 1
  }
else
  _omb_util_readlink_visited_init="local -a visited=()"
  function _omb_util_readlink__visited {
    local key
    for key in "${visited[@]}"; do
      [[ $1 == "$key" ]] && return 0
    done
    visited=("$1" "${visited[@]}")
    return 1
  }
fi

## @fn _omb_util_readlink__readlink path
##   @var[out] link
function _omb_util_readlink__readlink {
  local path=$1
  if _omb_util_function_exists readlink; then
    link=$(readlink -- "$path")
    [[ $link ]]
  elif _omb_util_binary_exists ls; then
    link=$(ls -ld -- "$path") &&
      [[ $link == *" $path -> "?* ]] &&
      link=${link#*" $path -> "}
  else
    false
  fi
} 2>/dev/null

## @fn  _omb_util_readlink__resolve_physical_directory
##   @var[in,out] path
function _omb_util_readlink__resolve_physical_directory {
  [[ $path == */?* ]] || return 0
  local PWD=$PWD OLDPWD=$OLDPWD CDPATH=
  builtin cd -L . &&
    local pwd=$PWD &&
    builtin cd -P "${path%/*}/" &&
    path=${PWD%/}/${path##*/}
  builtin cd -L "$pwd"
  return 0
}

function _omb_util_readlink__resolve_loop {
  local path=$1
  builtin eval -- "$_omb_util_readlink_visited_init"
  while [[ -h $path ]]; do
    local link
    _omb_util_readlink__visited "$path" && break
    _omb_util_readlink__readlink "$path" || break
    if [[ $link == /* || $path != */* ]]; then
      path=$link
    else
      _omb_util_readlink__resolve_physical_directory
      path=${path%/}/$link
    fi
    while [[ $path == ?*/ ]]; do path=${path%/}; done
  done
  echo "$path"
}

function _omb_util_readlink__resolve {
  # Select implementation on the first call
  _omb_util_readlink_type=

  case $OSTYPE in
  (cygwin | msys | linux-gnu)
    # These systems provide "readlink -f".
    local readlink
    readlink=$(type -P readlink)
    case $readlink in
    (/bin/readlink | /usr/bin/readlink)
      # shellcheck disable=SC2100
      _omb_util_readlink_type=readlink-f
      function _omb_util_readlink__resolve { readlink -f -- "$1"; } ;;
    esac ;;
  esac

  if [[ ! $_omb_util_readlink_type ]]; then
    _omb_util_readlink_type=loop
    function _omb_util_readlink__resolve { _omb_util_readlink__resolve_loop "$1"; }
  fi

  _omb_util_readlink__resolve "$1"
}

function _omb_util_readlink {
  if [[ -h $1 ]]; then
    _omb_util_readlink__resolve "$1"
  else
    echo "$1"
  fi
}
