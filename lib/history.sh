#! bash oh-my-bash.module

# A part of this file came from bash-sensible [1].  The current version is
# based on commit eb82f9e8.
#
# [1] https://github.com/mrzool/bash-sensible
#     Copyright (c) 2015 Mattia Tezzele, provided under the MIT license.

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
#
# Note: There are multiple ways to realize the unlimited history size.
#
# 1) A documented way is HISTSIZE=-1.  However, this is only supported in bash
#   >= 4.3 and it causes clearing the user's history in bash < 4.3.  Even if
#   we use HISTSIZE=-1 only when the current Bash version is 4.3 or above, it
#   clears the user's history file when a lower version of Bash is in the
#   system and it is started without setting HISTSIZE (e.g. when the Bash is
#   started with --norc or the specified init file is broken).  One could
#   consider giving up making HISTSIZE and HISTFILESIZE environment variables,
#   but then it truncates the user's history file when a new Bash is started
#   without setting HISTSIZE.
#
# 2) Another well known trick is to set HISTSIZE and HISTFILESIZE to an empty
#   string.  This works as unlimited history in all the Bash versions.
#   However, an empty HISTSIZE environment variable causes a startup error in
#   Mksh.  One could consider giving up making HISTSIZE environment variable,
#   but again, this will truncate the user's history file with Bash without
#   configuration.  One might consider defining a shell function or an alias to
#   start mksh without the HISTSIZE environment variable, but the users
#   wouldn't like it.  In addition, the truncated history problem persists with
#   the child Bash started within persists.
#
# 3) We instead consider explicitly specifying to HISTSIZE a large number that
#   is unlikely to be reached.  A typical value might be 10000 or 100000, but
#   that can still be reached by heavy users.  We instead specify a number as
#   large as possible.  The number shall not exceed INT_MAX, or otherwise
#   HISTSIZE becomes negative and clears the user's history.  In case there is
#   a system where `int' is a 16-bit signed integer, we choose 0x7FFF7FFF so
#   that the lower word is 0x7FFF.  This still does not ensure that the 16-bit
#   integer becomes 0x7FFF after overflow (since the overflow of the signed
#   integer causes the undefined behavior in the C standard), but it is safer
#   in typical implementations.
#
# See discussion on https://github.com/ohmybash/oh-my-bash/issues/586.
export HISTSIZE=$((0x7FFF7FFF))
export HISTFILESIZE=$((0x7FFF7FFF))

# Avoid duplicate entries
HISTCONTROL="erasedups:ignoreboth"

# Don't record some commands
HISTIGNORE="exit:ls:bg:fg:history:clear"

# Enable incremental history search with up/down arrows (also Readline goodness)
# Learn more about this here: https://codeinthehole.com/tips/the-most-important-command-line-tip-incremental-history-searching-with-inputrc/
# bash4 specific ??
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
bind '"\e[C": forward-char'
bind '"\e[D": backward-char'

# Use standard ISO 8601 timestamp
# %F equivalent to %Y-%m-%d
# %T equivalent to %H:%M:%S (24-hours format)

# Show history
case $HIST_STAMPS in
  "[mm/dd/yyyy]") HISTTIMEFORMAT=$'\033[31m[%m/%d/%Y] \033[36m[%T]\033[0m ' ;;
  "[dd.mm.yyyy]") HISTTIMEFORMAT=$'\033[31m[%d.%m.%Y] \033[36m[%T]\033[0m ' ;;
  "[yyyy-mm-dd]") HISTTIMEFORMAT=$'\033[31m[%F] \033[36m[%T]\033[0m ' ;;
  "mm/dd/yyyy") HISTTIMEFORMAT='%m/%d/%Y %T ' ;;
  "dd.mm.yyyy") HISTTIMEFORMAT='%d.%m.%Y %T ' ;;
  "yyyy-mm-dd"|*) HISTTIMEFORMAT='%F %T ' ;;
esac
