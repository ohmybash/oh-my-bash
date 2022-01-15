#! bash oh-my-bash.module
# Add completion for Makefile
# see http://stackoverflow.com/a/38415982/1472048
complete -W "\$(shopt -u nullglob; shopt -s nocaseglob; command grep -oE '^[a-zA-Z0-9_-]+:([^=]|\$)' *makefile 2>/dev/null | command sed 's/[^a-zA-Z0-9_-]*\$//')" make
