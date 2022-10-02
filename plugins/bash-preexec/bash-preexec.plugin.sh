#! bash oh-my-bash.module
if [[ ! ${bash_preexec_imported:-${__bp_imported:-}} ]]; then
  source "$OSH/tools/bash-preexec.sh"
fi
