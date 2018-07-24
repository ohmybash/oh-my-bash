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

# Faster Change Directory up
function bu () {
  function bu_usage () {
     cat <<-EOF
      Usage: bu [N]
              N        N is the number of level to move back up to, this argument must be a positive integer.
              h help   displays this basic help menu.
      EOF
  }

  # reset variables
  STRARGMNT=""
  FUNCTIONARG=$1

  # Make sure the provided argument is a positive integer:
  if [[ ! -z "${FUNCTIONARG##*[!0-9]*}" ]]; then
    for i in $(seq 1 $FUNCTIONARG); do
        STRARGMNT+="../"
    done
    CMD="cd ${STRARGMNT}"
    eval $CMD
  else
    bu_usage
  fi
}
