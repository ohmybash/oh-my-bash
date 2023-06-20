#! bash oh-my-bash.module
# Common directories functions

_omb_util_alias md='mkdir -p'
_omb_util_alias rd='rmdir'
_omb_util_alias d='dirs -v | head -10'
_omb_util_alias po='popd'

# List directory contents
_omb_util_alias lsa='ls -lha'
_omb_util_alias l='ls -lha'
_omb_util_alias ll='ls -lh'
_omb_util_alias la='ls -lhA'

# From bourne-shell.sh (unused)
#_omb_util_alias l='ls -CF'
#_omb_util_alias ll='ls -laF'
#_omb_util_alias la='ls -A'
