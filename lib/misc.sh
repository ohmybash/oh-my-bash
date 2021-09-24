#! bash oh-my-bash.module
## jobs
#setopt long_list_jobs

## pager
env_default PAGER 'less'
env_default LESS '-R'

## super user alias
_omb_util_alias _='sudo'
_omb_util_alias please='sudo'

## more intelligent acking for ubuntu users
if _omb_util_binary_exists ack-grep; then
  _omb_util_alias afind='ack-grep -il'
else
  _omb_util_alias afind='ack -il'
fi

# only define LC_CTYPE if undefined
if [[ -z "$LC_CTYPE" && -z "$LC_ALL" ]]; then
  export LC_CTYPE=${LANG%%:*} # pick the first entry from LANG
fi

# recognize comments
shopt -s interactive_comments
