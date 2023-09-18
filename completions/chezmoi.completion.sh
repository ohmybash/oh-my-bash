#! bash oh-my-bash.module

if _omb_util_command_exists chezmoi; then
    eval -- "$(chezmoi completion bash)"
fi
