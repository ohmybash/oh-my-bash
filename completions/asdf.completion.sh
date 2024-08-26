#! bash oh-my-bash.module
# Bash completion support for the `asdf` command.
# Depends on the `asdf` plugin.

# Only load the completions if the ASDF_DIR variable was set.
if [[ -v ASDF_DIR ]]; then
  . "$ASDF_DIR/completions/asdf.bash"
fi
