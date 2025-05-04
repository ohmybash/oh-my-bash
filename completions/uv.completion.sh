#! bash oh-my-bash.module

# uv (Python package and project manager) completion
# https://docs.astral.sh/uv/reference/cli/#uv-generate-shell-completion

if _omb_util_command_exists uv; then
  eval "$(uv generate-shell-completion bash)"
fi
