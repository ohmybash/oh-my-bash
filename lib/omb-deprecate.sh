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


# lib/utils.sh -- Logging functions
_omb_util_defun_deprecate 20000 type_exists _omb_util_binary_exists

_omb_util_defun_deprecate 20000 _omb_log_header    e_header
_omb_util_defun_deprecate 20000 _omb_log_arrow     e_arrow
_omb_util_defun_deprecate 20000 _omb_log_success   e_success
_omb_util_defun_deprecate 20000 _omb_log_error     e_error
_omb_util_defun_deprecate 20000 _omb_log_warning   e_warning
_omb_util_defun_deprecate 20000 _omb_log_underline e_underline
_omb_util_defun_deprecate 20000 _omb_log_bold      e_bold
_omb_util_defun_deprecate 20000 _omb_log_note      e_note
