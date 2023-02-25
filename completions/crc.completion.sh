#! bash oh-my-bash.module
if _omb_util_command_exists crc; then
  eval -- "$(crc completion bash)"
fi
