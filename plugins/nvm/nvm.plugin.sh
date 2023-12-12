#! bash oh-my-bash.module
# Description: automatically load nvm
#
# @var[opt] OMB_PLUGIN_NVM_AUTO_USE enable .nvmrc autoload

# Set NVM_DIR if it isn't already defined
[[ -z "$NVM_DIR" ]] && export NVM_DIR="$HOME/.nvm"


# Try to load nvm only if command not already available
if ! _omb_util_command_exists nvm; then
  # shellcheck source=/dev/null
  [[ -s $NVM_DIR/nvm.sh ]] && source "$NVM_DIR/nvm.sh"
fi

#------------------------------------------------------------------------------
# Optional .nvmrc autoload
#
# This part is originally from the official nvm documentation
# (README.md).  Here is the license of the original project:
#
# The MIT License (MIT)
#
# Copyright (c) 2010 Tim Caswell
# Copyright (c) 2014 Jordan Harband
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
if _omb_util_command_exists nvm && [[ ${OMB_PLUGIN_NVM_AUTO_USE-} == true ]]; then
  function _omb_plugin_nvm_find_up {
    local path=$PWD
    while [[ $path && ! -e $path/$1 ]]; do
      path=${path%/*}
    done
    echo "$path"
  }

  function _omb_plugin_nvm_cd {
    cd "$@" || return "$?"
    local nvm_path=$(_omb_plugin_nvm_find_up .nvmrc)

    # If there are no .nvmrc file, use the default nvm version
    if [[ $nvm_path != *[^[:space:]]* ]]; then

      local default_version
      default_version=$(nvm version default)

      # If there is no default version, set it to `node`
      # This will use the latest version on your machine
      if [[ $default_version == "N/A" ]]; then
        nvm alias default node
        default_version=$(nvm version default)
      fi

      # If the current version is not the default version, set it to use the default version
      if [[ $(nvm current) != "$default_version" ]]; then
        nvm use default
      fi

    elif [[ -s $nvm_path/.nvmrc && -r $nvm_path/.nvmrc ]]; then
      local nvm_version
      nvm_version=$(< "$nvm_path"/.nvmrc)

      local locally_resolved_nvm_version
      # `nvm ls` will check all locally-available versions.  If there are
      # multiple matching versions, take the latest one.  Remove the `->` and
      # `*` characters and spaces.  `locally_resolved_nvm_version` will be
      # `N/A` if no local versions are found.
      locally_resolved_nvm_version=$(nvm ls --no-colors $(<"./.nvmrc") | sed -n '${s/->//g;s/[*[:space:]]//g;p;}')

      # If it is not already installed, install it
      if [[ $locally_resolved_nvm_version == N/A ]]; then
        nvm install "$nvm_version"
      elif [[ $(nvm current) != "$locally_resolved_nvm_version" ]]; then
        nvm use "$nvm_version"
      fi
    fi
  }
  alias cd='_omb_plugin_nvm_cd'
fi
#------------------------------------------------------------------------------
