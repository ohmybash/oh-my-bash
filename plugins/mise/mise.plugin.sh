#! bash oh-my-bash.module
# Description: Integrate mise (https://mise.jdx.dev), a polyglot tool version manager
#
# @var[opt] OMB_PLUGIN_MISE_QUIET set to 'true' to suppress mise activation output

# Resolve the mise binary: check PATH first, then the default install location
# used by the official installer (curl https://mise.run | sh), then any custom
# install path set via MISE_INSTALL_PATH.
_omb_plugin_mise_bin=
if _omb_util_command_exists mise; then
  _omb_plugin_mise_bin=mise
elif [[ -x "${MISE_INSTALL_PATH:-}" ]]; then
  _omb_plugin_mise_bin=$MISE_INSTALL_PATH
elif [[ -x "$HOME/.local/bin/mise" ]]; then
  _omb_plugin_mise_bin=$HOME/.local/bin/mise
fi

if [[ -n $_omb_plugin_mise_bin ]]; then
  if [[ ${OMB_PLUGIN_MISE_QUIET-} == true ]]; then
    eval "$("$_omb_plugin_mise_bin" activate bash --quiet)"
  else
    eval "$("$_omb_plugin_mise_bin" activate bash)"
  fi

  # Use the resolved binary path in aliases so they work even when mise is
  # not yet on $PATH (e.g. installed via MISE_INSTALL_PATH or ~/.local/bin).
  local _omb_plugin_mise_bin_q
  printf -v _omb_plugin_mise_bin_q '%q' "$_omb_plugin_mise_bin"
  alias mi="$_omb_plugin_mise_bin_q install"
  alias mu="$_omb_plugin_mise_bin_q use"
  alias mr="$_omb_plugin_mise_bin_q run"
  alias mex="$_omb_plugin_mise_bin_q exec"
  alias mls="$_omb_plugin_mise_bin_q ls"
  alias mlsr="$_omb_plugin_mise_bin_q ls-remote"
  unset -v _omb_plugin_mise_bin_q
fi
unset _omb_plugin_mise_bin
