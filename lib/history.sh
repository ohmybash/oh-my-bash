#! bash oh-my-bash.module
shopt -s histappend # append to bash_history if Terminal.app quits

## Command history configuration
if [ -z "$HISTFILE" ]; then
  HISTFILE=$HOME/.bash_history
fi


# some moderate history controls taken from sensible.bash
## SANE HISTORY DEFAULTS ##

# Append to the history file, don't overwrite it
shopt -s histappend

# Save multi-line commands as one command
shopt -s cmdhist

# Re-edit the command line for failing history expansions
shopt -s histreedit

# Re-edit the result of history expansions
shopt -s histverify

# save history with newlines instead of ; where possible
shopt -s lithist

# Record each line as it gets issued
_omb_util_add_prompt_command 'history -a'

# Unlimited history size. Doesn't appear to slow things down, so why not?
# Export these variables to apply them also to the child shell sessions.
export HISTSIZE=
export HISTFILESIZE=

# Avoid duplicate entries
HISTCONTROL="erasedups:ignoreboth"

# Don't record some commands
export HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history:clear"

# Use standard ISO 8601 timestamp
# %F equivalent to %Y-%m-%d                                                                                      
# %T equivalent to %H:%M:%S (24-hours format)
HISTTIMEFORMAT='%F %T '

# Enable incremental history search with up/down arrows (also Readline goodness)
# Learn more about this here: http://codeinthehole.com/writing/the-most-important-command-line-tip-incremental-hi
# bash4 specific ??
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
bind '"\e[C": forward-char'
bind '"\e[D": backward-char'

# Show history
#case $HIST_STAMPS in
  #"mm/dd/yyyy") alias history='fc -fl 1' ;;
  #"dd.mm.yyyy") alias history='fc -El 1' ;;
  #"yyyy-mm-dd") alias history='fc -il 1' ;;
  #*) alias history='fc -l 1' ;;
#esac
