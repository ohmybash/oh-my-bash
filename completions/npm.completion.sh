#! bash oh-my-bash.module

# npm (Node Package Manager) completion
# https://docs.npmjs.com/cli/completion

if _omb_util_command_exists npm; then
  # Load completions even when Corepack selects a different package manager.
  eval -- "$(COREPACK_ENABLE_PROJECT_SPEC=0 npm completion)"
fi
