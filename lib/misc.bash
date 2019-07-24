#!/usr/bin/env bash
## jobs
#setopt long_list_jobs

## pager
env_default PAGER 'less'
env_default LESS '-R'

## super user alias
alias _='sudo'
alias please='sudo'

## more intelligent acking for ubuntu users
if which ack-grep &> /dev/null; then
  alias afind='ack-grep -il'
else
  alias afind='ack -il'
fi

# only define LC_CTYPE if undefined
if [[ -z "$LC_CTYPE" && -z "$LC_ALL" ]]; then
  export LC_CTYPE=${LANG%%:*} # pick the first entry from LANG
fi

# recognize comments
shopt -s interactive_comments
