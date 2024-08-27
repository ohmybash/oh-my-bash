#! bash oh-my-bash.module
# Bash completion support for the `asdf` command.
# Depends on the `asdf` plugin.

# Only load the completions if the ASDF_DIR variable was set.
if [[ ${ASDF_DIR+set} ]]; then
  . "$ASDF_DIR/completions/asdf.bash"
fi
