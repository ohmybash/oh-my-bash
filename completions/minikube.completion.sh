#! bash oh-my-bash.module

# minikube (Kubernetes CLI) completion

if command -v minikube &>/dev/null
then
  eval "$(minikube completion bash)"
fi
