#! bash oh-my-bash.module
# scm themeing
SCM_THEME_PROMPT_DIRTY="×"
SCM_THEME_PROMPT_CLEAN="✓"
SCM_THEME_PROMPT_PREFIX=""
SCM_THEME_PROMPT_SUFFIX=""

# TODO: need a check for OS before adding this to the prompt
# ${debian_chroot:+($debian_chroot)}

#added TITLEBAR for updating the tab and window titles with the pwd
case $TERM in
	xterm*)
	TITLEBAR='\[\033]0;\w\007\]'
	;;
	*)
	TITLEBAR=""
	;;
esac

function _omb_theme_PROMPT_COMMAND() {
    PROMPT='${_omb_prompt_green}\u${_omb_prompt_normal}@${_omb_prompt_green}\h${_omb_prompt_normal}:${_omb_prompt_navy}\w${_omb_prompt_normal}${_omb_prompt_brown}$(prompt_char)$(git_prompt_info)${_omb_prompt_normal}\$ '
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
