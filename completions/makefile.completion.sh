# Add completion for Makefile
# see http://stackoverflow.com/a/38415982/1472048
complete -W "\`find . -maxdepth 1 -iname '*makefile' -exec grep -oE '^[a-zA-Z0-9_-]+:([^=]|$)' {} \; | sed 's/[^a-zA-Z0-9_-]*$//'\`" make
