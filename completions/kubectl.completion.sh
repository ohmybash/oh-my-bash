#! bash oh-my-bash.module

# kubectl (Kubernetes CLI) completion

if command -v kubectl &>/dev/null
then
  eval "$(kubectl completion bash)"
fi
