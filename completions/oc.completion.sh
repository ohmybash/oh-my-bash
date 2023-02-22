#! bash oh-my-bash.module
if _omb_util_command_exists oc; then
  eval -- "$(oc completion bash)"
fi
