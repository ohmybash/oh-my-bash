#! bash oh-my-bash.module
# Copyright (c) 2010, Huy Nguyen, https://everyhue.me
# Copyright (c) 2015, Toan Nguyen, https://nntoan.github.io
# All rights reserved.
#
# This plugin is derived from the project https://github.com/huing/bashmarks.
# This version is based on the following commit in the upstream project:
#
#   https://github.com/huyng/bashmarks/commit/264952f2225691b5f99a498e4834e2c69bf4f5f5
#
# This plugin is licensed under the BSD-3 License.
#------------------------------------------------------------------------------
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#     * Redistributions of source code must retain the above copyright notice,
#       this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of Huy Nguyen nor the names of contributors may be
#       used to endorse or promote products derived from this software without
#       specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#------------------------------------------------------------------------------

# USAGE:
# bm -a bookmarkname - saves the curr dir as bookmarkname
# bm -g bookmarkname - jumps to the that bookmark
# bm -g b[TAB] - tab completion is available
# bm -p bookmarkname - prints the bookmark
# bm -p b[TAB] - tab completion is available
# bm -d bookmarkname - deletes the bookmark
# bm -d [TAB] - tab completion is available
# bm -l - list all bookmarks

# Default configurations
if [[ ! ${BASHMARKS_SDIRS-} ]]; then
  BASHMARKS_SDIRS=${SDIRS:-$HOME/.sdirs}
fi

# Deprecated interfaces (2023-10-12)
_omb_deprecate_declare  20000 SDIRS                 BASHMARKS_SDIRS sync
_omb_deprecate_function 20000 _echo_usage           _bashmarks_usage
_omb_deprecate_function 20000 _save_bookmark        _bashmarks_save
_omb_deprecate_function 20000 _delete_bookmark      _bashmarks_delete
_omb_deprecate_function 20000 _goto_bookmark        _bashmarks_goto
_omb_deprecate_function 20000 _list_bookmark        _bashmarks_list
_omb_deprecate_function 20000 _print_bookmark       _bashmarks_print
_omb_deprecate_function 20000 _l                    _bashmarks_list_names
_omb_deprecate_function 20000 _bookmark_name_valid  _bashmarks_is_valid_bookmark_name
_omb_deprecate_function 20000 _comp                 _bashmarks_comp_cmd_bm
_omb_deprecate_function 20000 _compzsh              _bashmarks_compzsh_cmd_bm
_omb_deprecate_function 20000 _purge_line           _bashmarks_purge_line

# setup file to store bookmarks
if [[ ! -e $BASHMARKS_SDIRS ]]; then
  touch "$BASHMARKS_SDIRS"
fi

# main function
function bm {
  local option=$1
  case $option in
    # save current directory to bookmarks [ bm -a BOOKMARK_NAME ]
    -a)
      _bashmarks_save "$2"
    ;;
    # delete bookmark [ bm -d BOOKMARK_NAME ]
    -d)
      _bashmarks_delete "$2"
    ;;
    # jump to bookmark [ bm -g BOOKMARK_NAME ]
    -g)
      _bashmarks_goto "$2"
    ;;
    # print bookmark [ bm -p BOOKMARK_NAME ]
    -p)
      _bashmarks_print "$2"
    ;;
    # show bookmark list [ bm -l ]
    -l)
      _bashmarks_list
    ;;
    # help [ bm -h ]
    -h)
      _bashmarks_usage
    ;;
    *)
      if [[ $1 == -* ]]; then
        # unrecognized option. echo error message and usage [ bm -X ]
        echo "Unknown option '$1'"
        _bashmarks_usage
        kill -SIGINT $$
        exit 1
      elif [[ $1 == "" ]]; then
        # no args supplied - echo usage [ bm ]
        _bashmarks_usage
      else
        # non-option supplied as first arg.  assume goto [ bm BOOKMARK_NAME ]
        _bashmarks_goto "$1"
      fi
    ;;
  esac
}

# print usage information
function _bashmarks_usage {
  echo 'USAGE:'
  echo "bm -h                   - Prints this usage info"
  echo 'bm -a <bookmark_name>   - Saves the current directory as "bookmark_name"'
  echo 'bm [-g] <bookmark_name> - Goes (cd) to the directory associated with "bookmark_name"'
  echo 'bm -p <bookmark_name>   - Prints the directory associated with "bookmark_name"'
  echo 'bm -d <bookmark_name>   - Deletes the bookmark'
  echo 'bm -l                   - Lists all available bookmarks'
}

# save current directory to bookmarks
function _bashmarks_save {
  if _bashmarks_is_valid_bookmark_name "$@"; then
    _bashmarks_purge_line "$BASHMARKS_SDIRS" "export DIR_$1="
    CURDIR=$(echo $PWD| sed "s#^$HOME#\$HOME#g")
    echo "export DIR_$1=\"$CURDIR\"" >> "$BASHMARKS_SDIRS"
  fi
}

# delete bookmark
function _bashmarks_delete {
  if _bashmarks_is_valid_bookmark_name "$@"; then
    _bashmarks_purge_line "$BASHMARKS_SDIRS" "export DIR_$1="
    unset "DIR_$1"
  fi
}

# jump to bookmark
function _bashmarks_goto {
  source "$BASHMARKS_SDIRS"
  local target_varname=DIR_$1
  local target=${!target_varname-}
  if [[ -d $target ]]; then
    cd "$target"
  elif [[ ! $target ]]; then
    printf '%s\n' "${_omb_term_brown}WARNING: '${1}' bashmark does not exist${_omb_term_reset}"
  else
    printf '%s\n' "${_omb_term_brown}WARNING: '${target}' does not exist${_omb_term_reset}"
  fi
}

# list bookmarks with dirname
function _bashmarks_list {
  source "$BASHMARKS_SDIRS"
  # if color output is not working for you, comment out the line below '\033[1;32m' == "red"
  env | sort | awk '/^DIR_.+/{split(substr($0,5),parts,"="); printf("\033[0;33m%-20s\033[0m %s\n", parts[1], parts[2]);}'
  # uncomment this line if color output is not working with the line above
  # env | grep "^DIR_" | cut -c5- | sort |grep "^.*="
}

# print bookmark
function _bashmarks_print {
  source "$BASHMARKS_SDIRS"
  echo "$(eval $(echo echo $(echo \$DIR_$1)))"
}

# list bookmarks without dirname
function _bashmarks_list_names {
  source "$BASHMARKS_SDIRS"
  env | grep "^DIR_" | cut -c5- | sort | grep "^.*=" | cut -f1 -d "="
}

# validate bookmark name
# @var[out] exit_message
function _bashmarks_is_valid_bookmark_name {
  local exit_message=""
  if [[ ! $1 ]]; then
    exit_message="bookmark name required"
    echo "$exit_message" >&2
    return 1
  elif [[ $1 == *[!A-Za-z0-9_]* ]]; then
    exit_message="bookmark name is not valid"
    echo "$exit_message" >&2
    return 1
  fi
}

# completion command
function _bashmarks_comp_cmd_bm {
  COMPREPLY=()

  # bm, g, p, d, bm -[gpd]
  if ((COMP_CWORD == 1)) || { ((COMP_CWORD >= 2)) && [[ ${COMP_WORDS[1]} == -[gpd] ]]; }; then
    local cur=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=($(compgen -W '$(_bashmarks_list_names)' -- "$cur"))
  fi

  return 0
}

# ZSH completion command
function _bashmarks_compzsh_cmd_bm {
  reply=($(_bashmarks_list_names))
}

# safe delete line from sdirs
function _bashmarks_purge_line {
  if [[ -s $1 ]]; then
    # safely create a temp file
    t=$(mktemp -t bashmarks.XXXXXX) || exit 1
    trap "/bin/rm -f -- '$t'" EXIT

    # purge line
    sed "/$2/d" "$1" >| "$t"
    /bin/mv "$t" "$1"

    # cleanup temp file
    /bin/rm -f -- "$t"
    trap - EXIT
  fi
}

# bind completion command for g,p,d to _bashmarks_comp_cmd_bm
if [[ ${ZSH_VERSION-} ]]; then
  compctl -K _bashmarks_compzsh_cmd_bm bm -g
  compctl -K _bashmarks_compzsh_cmd_bm bm -p
  compctl -K _bashmarks_compzsh_cmd_bm bm -d
  compctl -K _bashmarks_compzsh_cmd_bm g
  compctl -K _bashmarks_compzsh_cmd_bm p
  compctl -K _bashmarks_compzsh_cmd_bm d
else
  shopt -s progcomp
  complete -F _bashmarks_comp_cmd_bm bm
  complete -F _bashmarks_comp_cmd_bm g
  complete -F _bashmarks_comp_cmd_bm p
  complete -F _bashmarks_comp_cmd_bm d
fi

alias s='bm -a'       # Save a bookmark [bookmark_name]
alias g='bm -g'       # Go to bookmark [bookmark_name]
alias p='bm -p'       # Print bookmark of a path [path]
alias d='bm -d'       # Delete a bookmark [bookmark_name]
