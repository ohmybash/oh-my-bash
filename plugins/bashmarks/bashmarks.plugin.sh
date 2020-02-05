#!/usr/bin/env bash
# Copyright (c) 2015, Toan Nguyen - https://nntoan.github.io
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are permitted provided
# that the following conditions are met:
#
#     * Redistributions of source code must retain the above copyright notice, this list of conditions
#       and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the
#       following disclaimer in the documentation and/or other materials provided with the distribution.
#     * Neither the name of Toan Nguyen Ngoc (aka NNToan) nor the names of contributors
#       may be used to endorse or promote products derived from this software without
#       specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.


# USAGE:
# bm -a bookmarkname - saves the curr dir as bookmarkname
# bm -g bookmarkname - jumps to the that bookmark
# bm -g b[TAB] - tab completion is available
# bm -p bookmarkname - prints the bookmark
# bm -p b[TAB] - tab completion is available
# bm -d bookmarkname - deletes the bookmark
# bm -d [TAB] - tab completion is available
# bm -l - list all bookmarks

# setup file to store bookmarks
if [ ! -n "$SDIRS" ]; then
    SDIRS=~/.sdirs
fi
touch $SDIRS

RED="0;31m"
GREEN="0;33m"

# main function
function bm {
  option="${1}"
  case ${option} in
    # save current directory to bookmarks [ bm -a BOOKMARK_NAME ]
    -a)
      _save_bookmark "$2"
    ;;
    # delete bookmark [ bm -d BOOKMARK_NAME ]
    -d)
      _delete_bookmark "$2"
    ;;
    # jump to bookmark [ bm -g BOOKMARK_NAME ]
    -g)
      _goto_bookmark "$2"
    ;;
    # print bookmark [ bm -p BOOKMARK_NAME ]
    -p)
      _print_bookmark "$2"
    ;;
    # show bookmark list [ bm -l ]
    -l)
      _list_bookmark
    ;;
    # help [ bm -h ]
    -h)
      _echo_usage
    ;;
    *)
      if [[ $1 == -* ]]; then
        # unrecognized option. echo error message and usage [ bm -X ]
        echo "Unknown option '$1'"
        _echo_usage
        kill -SIGINT $$
        exit 1
      elif [[ $1 == "" ]]; then
        # no args supplied - echo usage [ bm ]
        _echo_usage
      else
        # non-option supplied as first arg.  assume goto [ bm BOOKMARK_NAME ]
        _goto_bookmark "$1"
      fi
    ;;
  esac
}

# print usage information
function _echo_usage {
  echo 'USAGE:'
  echo "bm -h                   - Prints this usage info"
  echo 'bm -a <bookmark_name>   - Saves the current directory as "bookmark_name"'
  echo 'bm [-g] <bookmark_name> - Goes (cd) to the directory associated with "bookmark_name"'
  echo 'bm -p <bookmark_name>   - Prints the directory associated with "bookmark_name"'
  echo 'bm -d <bookmark_name>   - Deletes the bookmark'
  echo 'bm -l                   - Lists all available bookmarks'
}

# save current directory to bookmarks
function _save_bookmark {
  _bookmark_name_valid "$@"
  if [ -z "$exit_message" ]; then
    _purge_line "$SDIRS" "export DIR_$1="
    CURDIR=$(echo $PWD| sed "s#^$HOME#\$HOME#g")
    echo "export DIR_$1=\"$CURDIR\"" >> $SDIRS
  fi
}

# delete bookmark
function _delete_bookmark {
  _bookmark_name_valid "$@"
  if [ -z "$exit_message" ]; then
    _purge_line "$SDIRS" "export DIR_$1="
    unset "DIR_$1"
  fi
}

# jump to bookmark
function _goto_bookmark {
    source $SDIRS
    target="$(eval $(echo echo $(echo \$DIR_$1)))"
    if [ -d "$target" ]; then
        cd "$target"
    elif [ ! -n "$target" ]; then
        echo -e "\033[${RED}WARNING: '${1}' bashmark does not exist\033[00m"
    else
        echo -e "\033[${RED}WARNING: '${target}' does not exist\033[00m"
    fi
}

# list bookmarks with dirname
function _list_bookmark {
    source $SDIRS
    # if color output is not working for you, comment out the line below '\033[1;32m' == "red"
    env | sort | awk '/DIR_.+/{split(substr($0,5),parts,"="); printf("\033[0;33m%-20s\033[0m %s\n", parts[1], parts[2]);}'
    # uncomment this line if color output is not working with the line above
    # env | grep "^DIR_" | cut -c5- | sort |grep "^.*="
}

# print bookmark
function _print_bookmark {
    source $SDIRS
    echo "$(eval $(echo echo $(echo \$DIR_$1)))"
}

# list bookmarks without dirname
function _l {
    source $SDIRS
    env | grep "^DIR_" | cut -c5- | sort | grep "^.*=" | cut -f1 -d "="
}

# validate bookmark name
function _bookmark_name_valid {
    exit_message=""
    if [ -z $1 ]; then
        exit_message="bookmark name required"
        echo $exit_message
    elif [ "$1" != "$(echo $1 | sed 's/[^A-Za-z0-9_]//g')" ]; then
        exit_message="bookmark name is not valid"
        echo $exit_message
    fi
}

# completion command
function _comp {
    local curw
    COMPREPLY=()
    curw=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=($(compgen -W '`_l`' -- $curw))
    return 0
}

# ZSH completion command
function _compzsh {
  reply=($(_l))
}

# safe delete line from sdirs
function _purge_line {
  if [ -s "$1" ]; then
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

# bind completion command for g,p,d to _comp
if [ $ZSH_VERSION ]; then
  compctl -K _compzsh bm -g
  compctl -K _compzsh bm -p
  compctl -K _compzsh bm -d
  compctl -K _compzsh g
  compctl -K _compzsh p
  compctl -K _compzsh d
else
  shopt -s progcomp
  complete -F _comp bm -g
  complete -F _comp bm -p
  complete -F _comp bm -d
  complete -F _comp g
  complete -F _comp p
  complete -F _comp d
fi

alias s='bm -a'       # Save a bookmark [bookmark_name]
alias g='bm -g'       # Go to bookmark [bookmark_name]
alias p='bm -p'       # Print bookmark of a path [path]
alias d='bm -d'       # Delete a bookmark [bookmark_name]
