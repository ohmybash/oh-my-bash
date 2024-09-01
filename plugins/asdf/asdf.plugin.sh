#! bash oh-my-bash.module
# asdf.plugin.sh: asdf plugin for oh-my-bash.
# Author: @RobLoach (https://github.com/robloach)
# Author: @prodrigues1912 (https://github.com/prodrigues1912)
# Originally suggested in https://github.com/ohmybash/oh-my-bash/pull/310
# Fork of the oh-my-zsh asdf plugin

# Custom ASDF_DIR location
if [[ ${ASDF_DIR+set} ]]; then
  . "$ASDF_DIR/asdf.sh"

# Home
elif [[ -f "$HOME/.asdf/asdf.sh" ]]; then
  ASDF_DIR="$HOME/.asdf"
  . "${ASDF_DIR}/asdf.sh"

# Config
elif [[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/asdf/asdf.sh" ]]; then
  ASDF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/asdf"
  . "${ASDF_DIR}/asdf.sh"

# Arch Linux / AUR Package
elif [[ -f "/opt/asdf-vm/asdf.sh" ]]; then
  ASDF_DIR="/opt/asdf-vm"
  . /opt/asdf-vm/asdf.sh

# Homebrew
elif _omb_util_command_exists brew; then
  _omb_plugin_asdf__prefix="$(brew --prefix asdf)"
  if [[ -f "$_omb_plugin_asdf__prefix/libexec/asdf.sh" ]]; then
    ASDF_DIR="$_omb_plugin_asdf__prefix/libexec"
    . "$ASDF_DIR/asdf.sh"
  fi
  unset -v _omb_plugin_asdf__prefix
fi
