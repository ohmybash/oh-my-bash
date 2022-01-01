#!/usr/bin/env bash

# is x grep argument available?
_omb_grep_flag_available() {
  echo | grep $1 "" >/dev/null 2>&1
}

_omb_grep_options=()

# color grep results
if _omb_grep_flag_available --color=auto; then
  _omb_grep_options+=( "--color=auto" )
fi

# ignore VCS folders (if the necessary grep flags are available)
_omb_grep_vcs_folders="{.bzr,CVS,.git,.hg,.svn}"

if _omb_grep_flag_available --exclude-dir=.cvs; then
  _omb_grep_options+=( "--exclude-dir=$_omb_grep_vcs_folders" )
elif _omb_grep_flag_available --exclude=.cvs; then
  _omb_grep_options+=( "--exclude=$_omb_grep_vcs_folders" )
fi

# export grep settings
if ((${#_omb_grep_options[@]} > 0)); then
  alias grep="grep ${_omb_grep_options[*]}"
fi

# clean up
unset -v _omb_grep_options
unset -v _omb_grep_vcs_folders
unset -f _omb_grep_flag_available
