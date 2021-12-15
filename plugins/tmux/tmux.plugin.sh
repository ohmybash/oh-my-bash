# @chopnico 2021

[ -z "$TMUX"  ] && { tmux -2 -u attach || exec tmux -2 -u new-session && exit;}
