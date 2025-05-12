#! bash oh-my-bash.module
# @chopnico 2021
# @NN--- 2025
#
# zellij-autoattach.plugin.sh
#
# A zellij plugin that will automatically attach itself to a bash session.
# This plugin is derived from tmux-autoattach.plugin.sh.

[[ ${OSH_PLUGIN_ZELLIJ_AUTOATTACH_BEHAVIOR-} ]] || OSH_PLUGIN_ZELLIJ_AUTOATTACH_BEHAVIOR="detach"

function _osh_plugin_zellij_autoattach_exit {
  [[ ! ${ZELLIJ-} ]] && zellij attach --create default && exit
}

function _osh_plugin_zellij_autoattach_detach {
  [[ ! ${ZELLIJ-} ]] && zellij attach --create default
}

case $OSH_PLUGIN_ZELLIJ_AUTOATTACH_BEHAVIOR in
'exit')
  _osh_plugin_zellij_autoattach_exit
  ;;
'detach' | *)
  _osh_plugin_zellij_autoattach_detach
  ;;
esac
