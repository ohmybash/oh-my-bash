#! bash oh-my-bash.module

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

_omb_util_defun_deprecate 20000 e_header    _omb_log_header
_omb_util_defun_deprecate 20000 e_arrow     _omb_log_arrow
_omb_util_defun_deprecate 20000 e_success   _omb_log_success
_omb_util_defun_deprecate 20000 e_error     _omb_log_error
_omb_util_defun_deprecate 20000 e_warning   _omb_log_warning
_omb_util_defun_deprecate 20000 e_underline _omb_log_underline
_omb_util_defun_deprecate 20000 e_bold      _omb_log_bold
_omb_util_defun_deprecate 20000 e_note      _omb_log_note
