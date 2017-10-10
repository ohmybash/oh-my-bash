#!/usr/bin/env bash
shopt -s histappend # append to bash_history if Terminal.app quits

## Command history configuration
if [ -z "$HISTFILE" ]; then
    HISTFILE=$HOME/.bash_history
fi

HISTSIZE=10000
SAVEHIST=10000

# Show history
#case $HIST_STAMPS in
  #"mm/dd/yyyy") alias history='fc -fl 1' ;;
  #"dd.mm.yyyy") alias history='fc -El 1' ;;
  #"yyyy-mm-dd") alias history='fc -il 1' ;;
  #*) alias history='fc -l 1' ;;
#esac

#shopt append_history
#shopt extended_history
#shopt hist_expire_dups_first
#shopt hist_ignore_dups # ignore duplication command history list
#shopt hist_ignore_space
#shopt hist_verify
#shopt inc_append_history
#shopt share_history # share command history data
