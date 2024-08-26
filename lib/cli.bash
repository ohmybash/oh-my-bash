#!/usr/bin/env bash

_omb_module_require lib:utils

function _omb_cmd_help {
  echo 'Not yet implemented'
}
function _omb_cmd_changelog {
  echo 'Not yet implemented'
}
function _omb_cmd_plugin {
  echo 'Not yet implemented'
}
function _omb_cmd_pull {
  echo 'Not yet implemented'
}
function _omb_cmd_reload {
  echo 'Not yet implemented'
}
function _omb_cmd_theme {
  echo 'Not yet implemented'
}
function _omb_cmd_update {
  echo 'Not yet implemented'
}
function _omb_cmd_version {
  echo 'Not yet implemented'
}

function omb {
  if (($# == 0)); then
    _omb_cmd_help
    return 2
  fi

  # Subcommand functions start with _ so that they don't
  # appear as completion entries when looking for `omb`
  if ! _omb_util_function_exists "_omb_cmd_$1"; then
    _omb_cmd_help
    return 2
  fi

  _omb_cmd_"$@"
}


_omb_module_require lib:utils

_omb_lib_cli__init_shopt=
_omb_util_get_shopt -v _omb_lib_cli__init_shopt extglob
shopt -s extglob

function _comp_cmd_omb__describe {
  eval "set -- $1 \"\${$2[@]}\""
  local type=$1; shift
  local word desc words iword=0
  for word; do
    desc="($type) ${word#*:}" # unused
    word=${word%%:*}
    words[iword++]=$word
  done

  local -a filtered
  _omb_util_split_lines filtered "$(compgen -W '"${words[@]}"' -- "${COMP_WORDS[COMP_CWORD]}")"
  COMPREPLY+=("${filtered[@]}")
}

function _comp_cmd_omb__get_available_plugins {
  available_plugins=()

  local -a plugin_files
  _omb_util_glob_expand plugin_files '{"$OSH","$OSH_CUSTOM"}/plugins/*/{_*,*.plugin.{bash,sh}}'

  local plugin
  for plugin in "${plugin_files[@]##*/}"; do
    case $plugin in
    *.plugin.bash) plugin=${plugin%.plugin.bash} ;;
    *.plugin.sh) plugin=${plugin%.plugin.sh} ;;
    *) plugin=${plugin#_} ;;
    esac

    _omb_util_array_contains available_plugins "$plugin" ||
      available_plugins+=("$plugin")
  done
}

function _comp_cmd_omb__get_available_themes {
  available_themes=()

  local -a theme_files
  _omb_util_glob_expand theme_files '{"$OSH","$OSH_CUSTOM"}/themes/*/{_*,*.theme.{bash,sh}}'

  local theme
  for theme in "${theme_files[@]##*/}"; do
    case $theme in
    *.theme.bash) theme=${theme%.theme.bash} ;;
    *.theme.sh) theme=${theme%.theme.sh} ;;
    *) theme=${theme#_} ;;
    esac

    _omb_util_array_contains available_themes "$theme" ||
      available_themes+=("$theme")
  done
}

## @fn _comp_cmd_omb__get_valid_plugins type
function _comp_cmd_omb__get_valid_plugins {
  if [[ $1 == disable ]]; then
    # if command is "disable", only offer already enabled plugins
    valid_plugins=("${plugins[@]}")
  else
    local -a available_plugins
    _comp_cmd_omb__get_available_plugins
    valid_plugins=("${available_plugins[@]}")

    # if command is "enable", remove already enabled plugins
    if [[ ${COMP_WORDS[2]} == enable ]]; then
      _omb_util_array_remove valid_plugins "${plugins[@]}"
    fi
  fi
}

function _comp_cmd_omb {
  local shopt
  _omb_util_get_shopt extglob
  shopt -s extglob

  if ((COMP_CWORD == 1)); then
    local -a cmds=(
      'changelog:Print the changelog'
      'help:Usage information'
      'plugin:Manage plugins'
      'pr:Manage Oh My Bash Pull Requests'
      'reload:Reload the current bash session'
      'theme:Manage themes'
      'update:Update Oh My Bash'
      'version:Show the version'
    )
    _comp_cmd_omb__describe 'command' cmds
  elif ((COMP_CWORD ==2)); then
    case "${COMP_WORDS[1]}" in
    changelog)
      local -a refs
      _omb_util_split_lines refs "$(command git -C "$OSH" for-each-ref --format="%(refname:short):%(subject)" refs/heads refs/tags)"
      _comp_cmd_omb__describe 'command' refs ;;
    plugin)
      local -a subcmds=(
        'disable:Disable plugin(s)'
        'enable:Enable plugin(s)'
        'info:Get plugin information'
        'list:List plugins'
        'load:Load plugin(s)'
      )
      _comp_cmd_omb__describe 'command' subcmds ;;
    pr)
      local -a subcmds=(
        'clean:Delete all Pull Request branches'
        'test:Test a Pull Request'
      )
      _comp_cmd_omb__describe 'command' subcmds ;;
    theme)
      local -a subcmds=(
        'list:List themes'
        'set:Set a theme in your .zshrc file'
        'use:Load a theme'
      )
      _comp_cmd_omb__describe 'command' subcmds ;;
    esac
  elif ((COMP_CWORD == 3)); then
    case "${COMP_WORDS[1]}::${COMP_WORDS[2]}" in
    plugin::@(disable|enable|load))
      local -a valid_plugins
      _comp_cmd_omb__get_valid_plugins "${COMP_WORDS[2]}"
      _comp_cmd_omb__describe 'plugin' valid_plugins ;;
    plugin::info)
      local -a available_plugins
      _comp_cmd_omb__get_available_plugins
      _comp_cmd_omb__describe 'plugin' available_plugins ;;
    theme::@(set|use))
      local -a available_themes
      _comp_cmd_omb__get_available_themes
      _comp_cmd_omb__describe 'theme' available_themes ;;
    esac
  elif ((COMP_CWORD > 3)); then
    case "${COMP_WORDS[1]}::${COMP_WORDS[2]}" in
    plugin::@(enable|disable|load))
      local -a valid_plugins
      _comp_cmd_omb__get_valid_plugins "${COMP_WORDS[2]}"

      # Remove plugins already passed as arguments
      # NOTE: $((COMP_CWORD - 1)) is the last plugin argument completely passed, i.e. that which
      # has a space after them. This is to avoid removing plugins partially passed, which makes
      # the completion not add a space after the completed plugin.
      _omb_util_array_remove valid_plugins "${COMP_WORDS[@]:3:COMP_CWORD-3}"

      _comp_cmd_omb__describe 'plugin' valid_plugins ;;
    esac
  fi

  [[ :$shopt: == *:exptglob:* ]] || shopt -u extglob
  return 0
}

complete -F _comp_cmd_omb omb

[[ :$_omb_lib_cli__init_shopt: == *:exptglob:* ]] || shopt -u extglob
unset -v _omb_lib_cli__init_shopt
