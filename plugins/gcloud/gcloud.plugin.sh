#!/bin/bash oh-my-bash.module
# gcloud.plugin.sh
# Author: Ian Chesal (github.com/ianchesal) -- ohmyzsh/gloud.plugin.zsh
# Author: Antonino Cangialosi (github.com/ninoCan)
# Fork of oh-my-zsh gcloud plugin

function _omb_plugin_gcloud_set_home_var() {
  if [[ ! ${OMB_PLUGIN_GCLOUD_HOME-} ]]; then
    local -a search_locations=(
      "$HOME/google-cloud-sdk"
      "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
      "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
      "/usr/share/google-cloud-sdk"
      "/snap/google-cloud-sdk/current"
      "/usr/lib/google-cloud-sdk"
      "/usr/lib64/google-cloud-sdk"
      "/opt/google-cloud-sdk"
      "/opt/local/libexec/google-cloud-sdk"
    )

    local gcloud_sdk_location
    for gcloud_sdk_location in "${search_locations[@]}"; do
      if [[ -d $gcloud_sdk_location ]]; then
        OMB_PLUGIN_GCLOUD_HOME=$gcloud_sdk_location
        break
      fi
    done
  fi
}

function _omb_plugin_gcloud_set_completions() {
  if [[ ${OMB_PLUGIN_GCLOUD_HOME-} ]]; then
    # Only source this if gcloud isn't already on the path
    if _omb_util_binary_exists gcloud; then
      if [[ -f $OMB_PLUGIN_GCLOUD_HOME/path.bash.inc ]]; then
        source "$OMB_PLUGIN_GCLOUD_HOME/path.bash.inc"
      fi

      # Look for completion file in different paths
      local -a completion_filepath_candidates=(
        "${OMB_PLUGIN_GCLOUD_HOME}/completion.bash.inc"    # default location
        "/usr/share/google-cloud-sdk/completion.bash.inc"  # apt-based location
      )
      local comp_file
      for comp_file in "${completion_filepath_candidates[@]}"; do
        if [[ -f $comp_file ]]; then
          source "$comp_file"
          break
        fi
      done
    fi
  fi
}

_omb_plugin_gcloud_set_home_var
_omb_plugin_gcloud_set_completions
