#! bash oh-my-bash.module

# minikube (Kubernetes CLI) completion

if _omb_util_command_exists minikube
then
  eval "$(minikube completion bash)"
fi
