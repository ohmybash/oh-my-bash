#! bash oh-my-bash.module

# Various shell options collected in single file
# taken from bash-sensible and other sources
## GENERAL OPTIONS ##

# Prevent file overwrite on stdout redirection
# Use `>|` to force redirection to an existing file
set -o noclobber

# Update window size after every command
shopt -s checkwinsize

# Automatically trim long paths in the prompt (requires Bash 4.x)
PROMPT_DIRTRIM=${PROMPT_DIRTRIM:-2}

# Enable history expansion with space
# E.g. typing !!<space> will replace the !! with your last command
bind Space:magic-space

# Turn on recursive globbing (enables ** to recurse all directories)
shopt -s globstar 2> /dev/null

# Case-sensitive globbing (used in pathname expansion) and matching
# (used in case, [[]], word expansions and command completions)
if [[ ${OMB_CASE_SENSITIVE:-${CASE_SENSITIVE:-}} == true ]]; then
   shopt -u nocaseglob
else
   shopt -s nocaseglob
fi

## SMARTER TAB-COMPLETION (Readline bindings) ##

# Conditionally perform file completion in a case insensitive fashion.
# Setting OMB_CASE_SENSITIVE to 'true' will switch from the default,
# case insensitive, matching to the case-sensitive one
#
# Note: CASE_SENSITIVE is the compatibility name
if [[ ${OMB_CASE_SENSITIVE:-${CASE_SENSITIVE:-}} == true ]]; then
	bind "set completion-ignore-case off"
else
	# By default, case sensitivity is disabled.
	bind "set completion-ignore-case on"

	# Treat hyphens and underscores as equivalent
	# CASE_SENSITIVE must be off
	if [[ ! ${OMB_HYPHEN_SENSITIVE-} && ${HYPHEN_INSENSITIVE} ]]; then
		case $HYPHEN_INSENSITIVE in
		(true)  OMB_HYPHEN_SENSITIVE=true ;;
		(false) OMB_HYPHEN_SENSITIVE=false ;;
		esac
	fi
	if [[ ${OMB_HYPHEN_SENSITIVE-} == false ]]; then
		bind "set completion-map-case on"
	fi
fi

# Display matches for ambiguous patterns at first tab press
bind "set show-all-if-ambiguous on"

# Immediately add a trailing slash when autocompleting symlinks to directories
bind "set mark-symlinked-directories on"

## BETTER DIRECTORY NAVIGATION ##

# Prepend cd to directory names automatically
shopt -s autocd 2> /dev/null
# Correct spelling errors during tab-completion
shopt -s dirspell 2> /dev/null
# Correct spelling errors in arguments supplied to cd
shopt -s cdspell 2> /dev/null

# This defines where cd looks for targets
# Add the directories you want to have fast access to, separated by colon
# Ex: CDPATH=".:~:~/projects" will look for targets in the current working directory, in home and in the ~/projec
CDPATH="."

# This allows you to bookmark your favorite places across the file system
# Define a variable containing a path and you will be able to cd into it regardless of the directory you're in
shopt -s cdable_vars
