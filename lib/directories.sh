#! bash oh-my-bash.module
# Common directories functions
_omb_util_alias cd..='cd ../'                         # Go back 1 directory level (for fast typers)
_omb_util_alias ..='cd ../'                           # Go back 1 directory level
_omb_util_alias ...='cd ../../'                       # Go back 2 directory levels
_omb_util_alias .3='cd ../../../'                     # Go back 3 directory levels
_omb_util_alias .4='cd ../../../../'                  # Go back 4 directory levels
_omb_util_alias .5='cd ../../../../../'               # Go back 5 directory levels
_omb_util_alias .6='cd ../../../../../../'            # Go back 6 directory levels

_omb_util_alias -='cd -'
_omb_util_alias 1='cd -'
_omb_util_alias 2='cd -2'
_omb_util_alias 3='cd -3'
_omb_util_alias 4='cd -4'
_omb_util_alias 5='cd -5'
_omb_util_alias 6='cd -6'
_omb_util_alias 7='cd -7'
_omb_util_alias 8='cd -8'
_omb_util_alias 9='cd -9'

_omb_util_alias md='mkdir -p'
_omb_util_alias rd='rmdir'
_omb_util_alias d='dirs -v | head -10'

# List directory contents
_omb_util_alias lsa='ls -lha'
_omb_util_alias l='ls -lha'
_omb_util_alias ll='ls -lh'
_omb_util_alias la='ls -lhA'

# From bourne-shell.sh (unused)
#_omb_util_alias l='ls -CF'
#_omb_util_alias ll='ls -laF'
#_omb_util_alias la='ls -A'
