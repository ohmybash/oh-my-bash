#! bash oh-my-bash.module

function _omb_deprecate_function__message {
  local old=$1 new=$2
  local v=__omb_util_DeprecateFunction_$old; v=${v//[!a-zA-Z0-9_]/'_'}
  [[ ${!v+set} ]] && return 0
  printf 'warning (oh-my-bash): %s\n' "\`$old' is deprecated. Use \`$new'." >&2
  printf -v "$v" done
}

function _omb_deprecate_function {
  local warning=
  ((_omb_version>=$1)) &&
    warning='_omb_deprecate_function__message "$2" "$3"; '
  builtin eval -- "function $2 { $warning$3 \"\$@\"; }"
}


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
_omb_deprecate_function 20000 type_exists _omb_util_binary_exists

_omb_deprecate_function 20000 e_header    _omb_log_header
_omb_deprecate_function 20000 e_arrow     _omb_log_arrow
_omb_deprecate_function 20000 e_success   _omb_log_success
_omb_deprecate_function 20000 e_error     _omb_log_error
_omb_deprecate_function 20000 e_warning   _omb_log_warning
_omb_deprecate_function 20000 e_underline _omb_log_underline
_omb_deprecate_function 20000 e_bold      _omb_log_bold
_omb_deprecate_function 20000 e_note      _omb_log_note

# themes/*
_omb_deprecate_function 20000 prompt_command  _omb_theme_PROMPT_COMMAND
_omb_deprecate_function 20000 prompt          _omb_theme_PROMPT_COMMAND
_omb_deprecate_function 20000 prompt_setter   _omb_theme_PROMPT_COMMAND
_omb_deprecate_function 20000 pure_setter     _omb_theme_PROMPT_COMMAND # pure, gallifrey
_omb_deprecate_function 20000 dulcie_setter   _omb_theme_PROMPT_COMMAND # dulcie
_omb_deprecate_function 20000 _brainy_setter  _omb_theme_PROMPT_COMMAND # brainy
_omb_deprecate_function 20000 set_bash_prompt _omb_theme_PROMPT_COMMAND # agnoster
