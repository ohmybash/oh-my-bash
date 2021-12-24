#!/usr/bin/env bash

function omb {
  [[ $# -gt 0 ]] || {
    _omb::help
    return 1
  }

  local command="$1"
  shift

  # Subcommand functions start with _ so that they don't
  # appear as completion entries when looking for `omb`
  (( $+functions[_omb::$command] )) || {
    _omb::help
    return 1
  }

  _omb::$command "$@"
}

function _omb {
  local -a cmds subcmds
  cmds=(
    'changelog:Print the changelog'
    'help:Usage information'
    'plugin:Manage plugins'
    'pr:Manage Oh My Bash Pull Requests'
    'reload:Reload the current bash session'
    'theme:Manage themes'
    'update:Update Oh My Bash'
    'version:Show the version'
  )

  if (( CURRENT == 2 )); then
    _describe 'command' cmds
  elif (( CURRENT == 3 )); then
    case "$words[2]" in
      changelog) local -a refs
        refs=("${(@f)$(cd "$OSH"; command git for-each-ref --format="%(refname:short):%(subject)" refs/heads refs/tags)}")
        _describe 'command' refs ;;
      plugin) subcmds=(
        'disable:Disable plugin(s)'
        'enable:Enable plugin(s)'
        'info:Get plugin information'
        'list:List plugins'
        'load:Load plugin(s)'
      )
        _describe 'command' subcmds ;;
      pr) subcmds=('clean:Delete all Pull Request branches' 'test:Test a Pull Request')
        _describe 'command' subcmds ;;
      theme) subcmds=('list:List themes' 'set:Set a theme in your .zshrc file' 'use:Load a theme')
        _describe 'command' subcmds ;;
    esac
  elif (( CURRENT == 4 )); then
    case "${words[2]}::${words[3]}" in
      plugin::(disable|enable|load))
        local -aU valid_plugins

        if [[ "${words[3]}" = disable ]]; then
          # if command is "disable", only offer already enabled plugins
          valid_plugins=($plugins)
        else
          valid_plugins=("$OSH"/plugins/*/{_*,*.plugin.zsh}(.N:h:t) "$OSH_CUSTOM"/plugins/*/{_*,*.plugin.zsh}(.N:h:t))
          # if command is "enable", remove already enabled plugins
          [[ "${words[3]}" = enable ]] && valid_plugins=(${valid_plugins:|plugins})
        fi

        _describe 'plugin' valid_plugins ;;
      plugin::info)
        local -aU plugins
        plugins=("$OSH"/plugins/*/{_*,*.plugin.zsh}(.N:h:t) "$OSH_CUSTOM"/plugins/*/{_*,*.plugin.zsh}(.N:h:t))
        _describe 'plugin' plugins ;;
      theme::(set|use))
        local -aU themes
        themes=("$OSH"/themes/*.zsh-theme(.N:t:r) "$OSH_CUSTOM"/**/*.zsh-theme(.N:r:gs:"$OSH_CUSTOM"/themes/:::gs:"$OSH_CUSTOM"/:::))
        _describe 'theme' themes ;;
    esac
  elif (( CURRENT > 4 )); then
    case "${words[2]}::${words[3]}" in
      plugin::(enable|disable|load))
        local -aU valid_plugins

        if [[ "${words[3]}" = disable ]]; then
          # if command is "disable", only offer already enabled plugins
          valid_plugins=($plugins)
        else
          valid_plugins=("$OSH"/plugins/*/{_*,*.plugin.zsh}(.N:h:t) "$OSH_CUSTOM"/plugins/*/{_*,*.plugin.zsh}(.N:h:t))
          # if command is "enable", remove already enabled plugins
          [[ "${words[3]}" = enable ]] && valid_plugins=(${valid_plugins:|plugins})
        fi

        # Remove plugins already passed as arguments
        # NOTE: $(( CURRENT - 1 )) is the last plugin argument completely passed, i.e. that which
        # has a space after them. This is to avoid removing plugins partially passed, which makes
        # the completion not add a space after the completed plugin.
        local -a args
        args=(${words[4,$(( CURRENT - 1))]})
        valid_plugins=(${valid_plugins:|args})

        _describe 'plugin' valid_plugins ;;
    esac
  fi

  return 0
}

compdef _omb omb