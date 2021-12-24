# @chopnico 2021
#
# tmux-autoattach.plugin.sh
#
# A tmux plugin that will automatically attach itself to a bash session.

[ -z "$OSH_PLUGIN_TMUX_AUTOATTACH_BEHAVIOR" ] && OSH_PLUGIN_TMUX_AUTOATTACH_BEHAVIOR="detach"

_osh_plugin_tmux_autoattach_exit() {
	[ -z "$TMUX" ] && tmux -2u new -A && exit
}

_osh_plugin_tmux_autoattach_detach() {
	[ -z "$TMUX" ] && tmux -2u new -A
}

case "$OSH_PLUGIN_TMUX_AUTOATTACH_BEHAVIOR" in
	"exit")
		_osh_plugin_tmux_autoattach_exit
		;;
	"detach" | *)
		_osh_plugin_tmux_autoattach_detach
		;;
esac
