#!/usr/bin/env bash
# is x grep argument available?
grep_flag_available() {
    echo | grep $1 "" >/dev/null 2>&1
}

GREP_OPTIONS=""

# color grep results
if grep_flag_available --color=auto; then
    GREP_OPTIONS+=( " --color=auto" )
fi

# ignore VCS folders (if the necessary grep flags are available)
VCS_FOLDERS="{.bzr,CVS,.git,.hg,.svn}"

if grep_flag_available --exclude-dir=.cvs; then
    GREP_OPTIONS+=( " --exclude-dir=$VCS_FOLDERS" )
elif grep_flag_available --exclude=.cvs; then
    GREP_OPTIONS+=( " --exclude=$VCS_FOLDERS" )
fi

# export grep settings
alias grep="grep $GREP_OPTIONS"

# clean up
unset GREP_OPTIONS
unset VCS_FOLDERS
unset -f grep_flag_available
