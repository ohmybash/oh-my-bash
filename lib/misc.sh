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


# poor man ssh-copy-id
# 1 - host 2 - identity file
ssh-id() {
def_id="~/.ssh/id_rsa.pub"
ssh_id=${$2-$def_id}
ssh $1 "mkdir -p .ssh && cat >> .ssh/authorized_keys" < $2
}

# self explanatory
rot13()
{ if [ $# = 0 ] ; then tr "[a-m][n-z][A-M][N-Z]" "[n-z][a-m][N-Z][A-M]";
  else tr "[a-m][n-z][A-M][N-Z]" "[n-z][a-m][N-Z][A-M]" < $1;
  fi
}

# poor man man
mmn () { nroff -man $1 | $PAGER; }
 
