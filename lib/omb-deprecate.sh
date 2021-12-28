#!/usr/bin/env bash

# deprecate functions

# oh-my-bash.sh -- These functions were originally used to find
# "fpath" directories, which are not supported by Bash.

is_plugin() {
  local base_dir=$1 name=$2
  [[ -f $base_dir/plugins/$name/$name.plugin.sh || -f $base_dir/plugins/$name/_$name ]]
}

is_completion() {
  local base_dir=$1 name=$2
  [[ -f $base_dir/completions/$name/$name.completion.sh ]]
}

is_alias() {
  local base_dir=$1 name=$2
  [[ -f $base_dir/aliases/$name/$name.aliases.sh ]]
}
