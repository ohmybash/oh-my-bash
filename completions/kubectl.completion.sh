#! bash oh-my-bash.module

# kubectl (Kubernetes CLI) completion

if _omb_util_command_exists kubectl; then
  # Note: We set KUBECONFIG=/dev/null to disable any kubectl plugins that take
  # time to initialize. For example, gke-gcloud-auth-plugin provided by Google
  # Cloud for GKE (Google Kubernetes Engine) seems to try to connect to an auth
  # server every time the kubectl command is executed, regardless of whether
  # the kubectl subcommand requires authentication. Since the generation of the
  # completion script should not depend on plugins, we temporarily disable all
  # plugins by setting a temporary environment KUBECONFIG=/dev/null.
  eval -- "$(KUBECONFIG=/dev/null kubectl completion bash)"
fi
