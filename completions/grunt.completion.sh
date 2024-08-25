#! bash oh-my-bash.module
#
# The current version is based on the following upstream version:
# https://github.com/gruntjs/grunt-cli/blob/8c791efc931fa8cf80cc98d09d3e20c36501fc0f/completion/bash#L33
#
# Note: The upstream version seems to have just updated the copyright year, but
# that change must be wrong.  Basically, the copyright year should reflect the
# year of the first release.  The years of later updates are optional.
#------------------------------------------------------------------------------
# grunt-cli
# http://gruntjs.com/
#
# Copyright (c) 2012 Tyler Kellen, contributors
# Licensed under the MIT license.
# https://github.com/gruntjs/grunt/blob/master/LICENSE-MIT

# Usage:
#
# To enable bash <tab> completion for grunt, add the following line (minus the
# leading #, which is the bash comment character) to your ~/.bashrc file:
#
# eval "$(grunt --completion=bash)"

# Search the current directory and all parent directories for a gruntfile.
function _grunt_gruntfile {
  local curpath=$PWD
  while [[ $curpath ]]; do
    local gruntfile
    for gruntfile in "$curpath"/{G,g}runtfile.{js,coffee}; do
      if [[ -e $gruntfile ]]; then
        echo "$gruntfile"
        return 0
      fi
    done
    curpath=${curpath%/*}
  done
  return 1
}

# Enable bash autocompletion.
function _grunt_completions {
  # The currently-being-completed word.
  local cur=${COMP_WORDS[COMP_CWORD]}
  # The current gruntfile, if it exists.
  local gruntfile=$(_grunt_gruntfile)
  # The current grunt version, available tasks, options, etc.
  local gruntinfo=$(grunt --version --verbose 2>/dev/null)
  # Options and tasks.
  local opts=$(awk '/Available options: / {$1=$2=""; print $0}' <<< "$gruntinfo")
  local compls=$(awk '/Available tasks: / {$1=$2=""; print $0}' <<< "$gruntinfo")
  # Only add -- or - options if the user has started typing -
  [[ $cur == -* ]] && compls="$compls $opts"
  # Tell complete what stuff to show.
  COMPREPLY=($(compgen -W "$compls" -- "$cur"))
}

complete -o default -F _grunt_completions grunt
