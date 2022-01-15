#! bash oh-my-bash.module
# bu.plugin.sh
# Author: Taleeb Midi <taleebmidi@gmail.com>
# Based on oh-my-zsh AWS plugin
#
# command 'bu [N]' Change directory up N times
#

# Faster Change Directory up
# shellcheck disable=SC2034
function bu () {
	function usage () {
		 cat <<-EOF
			Usage: bu [N]
							N        N is the number of level to move back up to, this argument must be a positive integer.
							h help   displays this basic help menu.
			EOF
	}
	# reset variables
	STRARGMNT=""
	FUNCTIONARG=$1
	# Make sure the provided argument is a positive integer:
	if [[ ! -z "${FUNCTIONARG##*[!0-9]*}" ]]; then
		for i in $(seq 1 $FUNCTIONARG); do
				STRARGMNT+="../"
		done
		CMD="cd ${STRARGMNT}"
		eval $CMD
	else
		usage
	fi
}
