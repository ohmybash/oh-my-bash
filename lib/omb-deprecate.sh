#! bash oh-my-bash.module

function _omb_deprecate_warning {
  local level=$1 msg=$2
  local sep=$_omb_term_teal:
  local src=$_omb_term_purple${BASH_SOURCE[level+1]}
  local line=$_omb_term_green${BASH_LINENO[level]}
  local func=${FUNCNAME[level+1]}
  if [[ $func && $func != source ]]; then
    func=" $_omb_term_teal($_omb_term_navy$func$_omb_term_teal)"
  else
    func=
  fi
  printf '%s\n' "$src$sep$line$func$sep$_omb_term_reset $msg"
}

function _omb_deprecate_function__notify {
  local old=$1 new=$2
  local v=__omb_deprecate_Function_$old; v=${v//[!a-zA-Z0-9_]/'_'}
  [[ ${!v+set} ]] && return 0
  local esc_old=$_omb_term_bold_brown$old$_omb_term_reset
  local esc_new=$_omb_term_bold_navy$new$_omb_term_reset
  _omb_deprecate_warning 2 "The function '$esc_old' is deprecated. Please use '$esc_new'." >&2
  printf -v "$v" notified
}

function _omb_deprecate_function {
  local warning=
  ((_omb_version >= $1)) &&
    warning="_omb_deprecate_function__notify '$2' '$3'; "
  builtin eval -- "function $2 { $warning$3 \"\$@\"; }"
}

## @fn _omb_deprecate_declare version old_name new_name opts arg
##   @param[in] version
##     The OMB version starting warning messages.
##
##   @param[in] old_name new_name
##     old and new variable names.  The empty value of new_name indicates that
##     the old_name is just deprecated, or there is no unique corresponding new
##     variable.
##
##   @param[in] opts
##     a colon-separated list of the following fields:
##
##     sync
##       detect changes in either of old variable and new variable, and apply
##       the change to the other.
##     track
##       copy from the new variable to the old variable when the value is
##       changed.
##
##   @param[in] arg
##     When new_name is not specified, arg contains an error message that will
##     be shown when the old_name is accessed.
##

## @fn _omb_deprecate_declare__init
##   @var[in] __ver __old __new __opts __msg
function _omb_deprecate_declare__init {
  if [[ ${!__old+set} ]]; then
    __opts=$__opts:notified
    if ((_omb_version >= __ver)); then
      if [[ $__new ]]; then
        printf '%s\n' "oh-my-bash: The variable '$__old' is set but has been renamed to '$__new'.  Please use '$__new'."
      else
        printf '%s\n' "oh-my-bash: The variable '$__old' is set but has been deprecated.${__msg+ $__msg}"
      fi >/dev/tty
    fi
    if [[ $__new && ! ${!__new+set} ]]; then
      printf -v "$__new" '%s' "${!__old}"
    fi
  fi
}
if ((_omb_bash_version >= 40300)); then
  _omb_deprecate_declare=()
  declare -gA _omb_deprecate_declare_counter=()
  function _omb_deprecate_declare {
    local __ver=$1 __old=$2 __new=$3 __opts=$4 __msg=$5
    _omb_deprecate_declare__init

    unset -n "$__old"
    unset -v "$__old"
    if ((_omb_version >= __ver)); then
      local __index=${#_omb_deprecate_declare[@]}
      _omb_deprecate_declare[__index]=$__old:$__new:$__msg
      eval "declare -gn $__old='$__new[_omb_deprecate_declare_counter[$__index,\$BASH_SOURCE,\$LINENO]+=\$(_omb_deprecate_declare__notify $__index),0]'"
    else
      eval "declare -gn $__old='$__new'"
    fi
  }
  function _omb_deprecate_declare__notify {
    local __index=$1 data=${_omb_deprecate_declare[__index]}
    local __old=${data%%:*}; data=${data#*:}
    local __new=${data%%:*}; data=${data#*:}
    local __msg=$data
    local count=${_omb_deprecate_declare_counter[$__index,${BASH_SOURCE[1]},${BASH_LINENO[0]}]:-0}
    if ((count == 0)); then
      local esc_old=$_omb_term_bold_brown$__old$_omb_term_reset
      local esc_new=$_omb_term_bold_navy$__new$_omb_term_reset
      if [[ $__new ]]; then
        _omb_deprecate_warning 1 "The variable '$esc_old' has been renamed to '$esc_new'. Please use '$esc_new'."
      else
        _omb_deprecate_warning 1 "The variable '$esc_old' has been deprecated.${__msg+ $__msg}"
      fi >/dev/tty
    fi
    echo 1
  }
else
  _omb_deprecate_declare=()
  _omb_deprecate_declare_notify=()
  _omb_deprecate_declare_value=()
  function _omb_deprecate_declare {
    local __ver=$1 __old=$2 __new=$3 __opts=$4 __msg=$5
    _omb_deprecate_declare__init

    if [[ ! $__new ]]; then
      # (show warning when used) nothing can be done for bash <= 4.2
      return 0
    fi

    local __notify=
    if ((_omb_version >= __ver)) && [[ :$__opts: != *:notified:* ]]; then
      __notify=1
    fi

    printf -v "$__old" %s "${!__new-}"
    if [[ :$__opts: == *:track:* ]]; then
      local __index=${#_omb_deprecate_declare[@]}
      _omb_deprecate_declare[__index]=track:$__old:$__new:$__msg
      _omb_deprecate_declare_notify[__index]=$__notify
    elif [[ :$__opts: == *:sync:* ]]; then
      local __index=${#_omb_deprecate_declare[@]}
      _omb_deprecate_declare[__index]=sync:$__old:$__new:$__msg
      _omb_deprecate_declare_notify[__index]=$__notify
      _omb_deprecate_declare_value[__index]=${__new}
    fi
  }
  function _omb_deprecate_declare__sync {
    local __index __pair __type __old __new __msg
    for __index in "${!_omb_util_deprecate[@]}"; do
      __pair=${_omb_util_deprecate[__index]}
      __type=${__pair%%:*} __pair=${__pair#*:}
      __old=${__pair%%:*} __pair=${__pair#*:}
      __new=${_pair%%:*} __msg=${__pair#*:}

      [[ ${!__new} != "$__value" || ${!__old} != "$__value" ]] || continue

      # Notify deprecation when the variable 'old_name' has been first changed.
      if [[ ${!__old+set} && ${!__old} != "$__value" && ${_omb_deprecate_declare_notify[__index]} ]]; then
        _omb_deprecate_declare_notify[__index]=
        local esc_old=$_omb_term_bold_brown$__old$_omb_term_reset
        local esc_new=$_omb_term_bold_navy$__new$_omb_term_reset
        if [[ $__new ]]; then
          printf '%s\n' "oh-my-bash: The variable '$esc_old' is changed but has been renamed to '$esc_new'.  Please use '$esc_new'."
        else
          printf '%s\n' "oh-my-bash: The variable '$esc_old' is changed but has been deprecated.${__msg+ $__msg}"
        fi >/dev/tty
      fi

      case $__type in
      (sync)
        local __value=${_omb_util_deprecate_value[__index]} __event=
        if [[ ! ${!__new+set} || ! ${!__old+set} ]]; then
          __value=${!__new-${!__old-}} __event=change
        elif [[ ${!__new} != "$__value" ]]; then
          __value=${!__new} __event=change
        elif [[ ${!__old} != "$__value" ]]; then
          __value=${!__old} __event=change
        fi

        if [[ $__event ]]; then
          _omb_util_deprecate_value[__index]=$__value
          printf -v "$__new" %s "$__value"
          printf -v "$__old" %s "$__value"
        fi ;;
      (track)
        printf -v "$__old" %s "${!__new-}" ;;
      esac
    done
  }
  _omb_util_add_prompt_command _omb_deprecate_declare__sync
fi

if ((_omb_bash_version >= 40300)); then
  _omb_deprecate_const=()
  _omb_deprecate_const_value=()
  declare -gA _omb_deprecate_const_counter=()
  function _omb_deprecate_const {
    local __ver=$1 __old=$2 __value=$3 __msg=$4
    if [[ ${!__old+set} ]]; then
      return 0
    fi

    if ((_omb_version >= __ver)); then
      local __index=${#_omb_deprecate_const[@]}
      _omb_deprecate_const[__index]=$__old:$__msg
      _omb_deprecate_const_value[__index]=$__value
      printf -v "_omb_deprecate_Const_$__old" %s "$__value"
      eval "declare -gn $__old='_omb_deprecate_Const_$__old[_omb_deprecate_const_counter[$__index,\$BASH_SOURCE,\$LINENO]+=\$(_omb_deprecate_const__notify $__index),0]'"
    else
      printf -v "$__old" %s "$__value"
    fi
  }
  function _omb_deprecate_const__notify {
    local __index=$1
    local __old=${_omb_deprecate_const[__index]%%:*}
    local __msg=${_omb_deprecate_const[__index]#*:}
    local __value=${_omb_deprecate_const_value[__index]}
    local __ref=_omb_deprecate_Const_$__old
    if [[ ${!__ref-} == "$__value" ]]; then
      local count=${_omb_deprecate_const_counter[$__index,${BASH_SOURCE[1]},${BASH_LINENO[0]}]:-0}
      if ((count == 0)); then
        local esc_old=$_omb_term_bold_brown$__old$_omb_term_reset
        _omb_deprecate_warning 1 "The variable '$esc_old' has been deprecated.${__msg+ $__msg}" >&2
      fi
    fi
    echo 1
  }
  function _omb_deprecate_const__sync {
    local __index __old __curval __compaction=
    for __index in "${!_omb_deprecate_const[@]}"; do
      __old=${_omb_deprecate_const[__index]%%:*}
      [[ $__old ]] || continue

      __ref=_omb_deprecate_Const_$__old
      __curval=${!__ref-}
      if [[ $__curval != "${_omb_deprecate_const_value[__index]}" ]]; then
        _omb_deprecate_const[__index]=
        _omb_deprecate_const_value[__index]=
        unset -n "$__old"
        printf -v "$__old" %s "$__curval"
      fi
    done
  }
  _omb_util_add_prompt_command _omb_deprecate_const__sync
else
  function _omb_deprecate_const {
    local __ver=$1 __old=$2 __value=$3 __msg=$4
    if [[ ${!__old+set} ]]; then
      return 0
    fi
    printf -v "$__old" %s "$__value"
  }
fi

_omb_deprecate_msg_please_use="Please use '$_omb_term_bold_navy%s$_omb_term_reset'."

#------------------------------------------------------------------------------
# deprecate functions and variables

# oh-my-bash.sh -- These functions were originally used to find
# "fpath" directories, which are not supported by Bash.

function is_plugin {
  local base_dir=$1 name=$2
  [[ -f $base_dir/plugins/$name/$name.plugin.sh || -f $base_dir/plugins/$name/_$name ]]
}

function is_completion {
  local base_dir=$1 name=$2
  [[ -f $base_dir/completions/$name/$name.completion.sh ]]
}

function is_alias {
  local base_dir=$1 name=$2
  [[ -f $base_dir/aliases/$name/$name.aliases.sh ]]
}

# lib/utils.sh -- Logging functions
_omb_deprecate_function 20000 type_exists _omb_util_binary_exists

_omb_deprecate_const 20000 ncolors   "$_omb_term_colors"    "${_omb_deprecate_msg_please_use/'%s'/_omb_term_colors}"
_omb_deprecate_const 20000 bold      "$_omb_term_bold"      "${_omb_deprecate_msg_please_use/'%s'/_omb_term_bold}"
_omb_deprecate_const 20000 underline "$_omb_term_underline" "${_omb_deprecate_msg_please_use/'%s'/_omb_term_underline}"
_omb_deprecate_const 20000 reset     "$_omb_term_reset"     "${_omb_deprecate_msg_please_use/'%s'/_omb_term_reset}"
_omb_deprecate_const 20000 tan       "$_omb_term_olive"    "${_omb_deprecate_msg_please_use/'%s'/_omb_term_olive}"

_omb_deprecate_red=${_omb_term_brown:+$'\1'$_omb_term_brown$'\2'}
_omb_deprecate_green=${_omb_term_green:+$'\1'$_omb_term_green$'\2'}
_omb_deprecate_yellow=${_omb_term_olive:+$'\1'$_omb_term_olive$'\2'}
_omb_deprecate_blue=${_omb_term_navy:+$'\1'$_omb_term_navy$'\2'}
_omb_deprecate_magenta=${_omb_term_purple:+$'\1'$_omb_term_purple$'\2'}
_omb_deprecate_const 20000 red       "$_omb_deprecate_red"     "Please use '${_omb_term_bold_navy}_omb_term_brown$_omb_term_reset' or '${_omb_term_bold_navy}_omb_prompt_brown$_omb_term_reset'."
_omb_deprecate_const 20000 green     "$_omb_deprecate_green"   "Please use '${_omb_term_bold_navy}_omb_term_green$_omb_term_reset' or '${_omb_term_bold_navy}_omb_prompt_green$_omb_term_reset'."
_omb_deprecate_const 20000 yellow    "$_omb_deprecate_yellow"  "Please use '${_omb_term_bold_navy}_omb_term_olive$_omb_term_reset' or '${_omb_term_bold_navy}_omb_prompt_olive$_omb_term_reset'."
_omb_deprecate_const 20000 blue      "$_omb_deprecate_blue"    "Please use '${_omb_term_bold_navy}_omb_term_navy$_omb_term_reset' or '${_omb_term_bold_navy}_omb_prompt_navy$_omb_term_reset'."
_omb_deprecate_const 20000 purple    "$_omb_deprecate_magenta" "Please use '${_omb_term_bold_navy}_omb_term_purple$_omb_term_reset' or '${_omb_term_bold_navy}_omb_prompt_purple$_omb_term_reset'."

_omb_deprecate_function 20000 e_header    _omb_log_header
_omb_deprecate_function 20000 e_arrow     _omb_log_arrow
_omb_deprecate_function 20000 e_success   _omb_log_success
_omb_deprecate_function 20000 e_error     _omb_log_error
_omb_deprecate_function 20000 e_warning   _omb_log_warning
_omb_deprecate_function 20000 e_underline _omb_log_underline
_omb_deprecate_function 20000 e_bold      _omb_log_bold
_omb_deprecate_function 20000 e_note      _omb_log_note

# plugins/bashmarks/bashmarks.plugin.sh [ This anyway conflicts with
#   variables defined by themes (axin, mairan, sexy, etc.) so do not
#   define fallbacks and warnings. ]
#_omb_deprecate_const RED   "0;31m" "${_omb_deprecate_msg_please_use/'%s'/\${_omb_term_brown:2}}"
#_omb_deprecate_const GREEN "0;33m" "${_omb_deprecate_msg_please_use/'%s'/\${_omb_term_green:2}}"

# themes/*
_omb_deprecate_function 20000 prompt_command  _omb_theme_PROMPT_COMMAND
_omb_deprecate_function 20000 prompt          _omb_theme_PROMPT_COMMAND
_omb_deprecate_function 20000 prompt_setter   _omb_theme_PROMPT_COMMAND
_omb_deprecate_function 20000 pure_setter     _omb_theme_PROMPT_COMMAND # pure, gallifrey
_omb_deprecate_function 20000 dulcie_setter   _omb_theme_PROMPT_COMMAND # dulcie
_omb_deprecate_function 20000 _brainy_setter  _omb_theme_PROMPT_COMMAND # brainy
_omb_deprecate_function 20000 set_bash_prompt _omb_theme_PROMPT_COMMAND # agnoster
