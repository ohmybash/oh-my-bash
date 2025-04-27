#! bash oh-my-bash.module
# bu.plugin.sh
# Author: Taleeb Midi <taleebmidi@gmail.com>
# Based on oh-my-zsh AWS plugin
#
# command 'bu [N]' Change directory up N times
#

function _omb_plugin_bu_usage {
  cat <<EOF
Usage: bu [N]
        N        N is the number of level to move back up to, this argument must be a positive integer.
        h help   displays this basic help menu.
EOF
}

# Faster Change Directory up
# shellcheck disable=SC2034
function bu {
  # reset variables
  local STRARGMNT=""
  local FUNCTIONARG=$1
  # Make sure the provided argument is a positive integer:
  if [[ $FUNCTIONARG && $FUNCTIONARG != *[!0-9]* ]]; then
    local i
    for ((i = 1; i <= FUNCTIONARG; i++)); do
      STRARGMNT+=../
    done
    cd "$STRARGMNT"
  else
    _omb_plugin_bu_usage
  fi
}
