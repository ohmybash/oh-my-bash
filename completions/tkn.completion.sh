#! bash oh-my-bash.module
if _omb_util_command_exists tkn; then
  eval -- "$(tkn completion bash)"
fi

if _omb_util_command_exists tkn-pac; then
  eval -- "$(tkn-pac completion bash)"
fi
