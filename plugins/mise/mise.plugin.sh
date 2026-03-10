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

  alias mi='mise install'
  alias mu='mise use'
  alias mr='mise run'
  alias mex='mise exec'
  alias mls='mise ls'
  alias mlsr='mise ls-remote'
fi
unset _omb_plugin_mise_bin
