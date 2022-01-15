# -*- mode: bash -*-

# kubectl (Kubernetes CLI) completion

if command -v kubectl &>/dev/null
then
  eval "$(kubectl completion bash)"
fi
