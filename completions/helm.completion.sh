#! bash oh-my-bash.module
if _omb_util_command_exists helm; then
  eval -- "$(helm completion bash)"
fi
