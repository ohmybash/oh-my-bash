#! bash oh-my-bash.module
# @chopnico 2021
#
# tmux-autoattach.plugin.sh
#
# A tmux plugin that will automatically attach itself to a bash session.

[ -z "$OSH_PLUGIN_TMUX_AUTOATTACH_BEHAVIOR" ] && OSH_PLUGIN_TMUX_AUTOATTACH_BEHAVIOR="detach"

# Note on the option "-As0": tmux-3.0a and before does not attach to a session
# as far as the session name is not given by "-s SESSION_NAME" [1].  From
# tmux-3.1, it attaches to an existing session, if any, without specifying the
# session.  Here, we assume the session name to be "0", which is the default
# name for the first session.
#
# [1] https://github.com/ohmybash/oh-my-bash/pull/332

function _osh_plugin_tmux_autoattach_exit {
	[ -z "$TMUX" ] && tmux -2u new -As0 && exit
}

function _osh_plugin_tmux_autoattach_detach {
	[ -z "$TMUX" ] && tmux -2u new -As0
}

case "$OSH_PLUGIN_TMUX_AUTOATTACH_BEHAVIOR" in
	"exit")
		_osh_plugin_tmux_autoattach_exit
		;;
	"detach" | *)
		_osh_plugin_tmux_autoattach_detach
		;;
esac
