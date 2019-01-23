#!/usr/bin/env bash
# A script to make using 256 colors in bash less painful.
# P.C. Shyamshankar <sykora@lucentbeing.com>
# Copied from http://github.com/sykora/etc/blob/master/zsh/functions/spectrum/


# typeset in bash does not have associative arrays, declare does in bash 4.0+
# https://stackoverflow.com/a/6047948

# This library only works for BASH 4.x to keep the minimum compatible for macOS.
# shellcheck disable=SC2034
if [ "${BASH_VERSINFO[0]}" -gt 4 ]; then 
  _RED='\033[0;31m' # Red Color (For error)
  _NC='\033[0m' # No Color (To reset the terminal color)

  declare -Ag FX FG BG

  FX=(
      [reset]="%{^[[00m%}"
      [bold]="%{^[[01m%}"       [no-bold]="%{^[[22m%}"
      [italic]="%{^[[03m%}"     [no-italic]="%{^[[23m%}"
      [underline]="%{^[[04m%}"  [no-underline]="%{^[[24m%}"
      [blink]="%{^[[05m%}"      [no-blink]="%{^[[25m%}"
      [reverse]="%{^[[07m%}"    [no-reverse]="%{^[[27m%}"
  )

  for color in {000..255}; do
      FG[$color]="%{^[[38;5;${color}m%}"
      BG[$color]="%{^[[48;5;${color}m%}"
  done


  OSH_SPECTRUM_TEXT=${OSH_SPECTRUM_TEXT:-Arma virumque cano Troiae qui primus ab oris}

  # Show all 256 colors with color number
  function spectrum_ls() {
    for code in {000..255}; do
      print -P -- "$code: %{$FG[$code]%}$OSH_SPECTRUM_TEXT%{$reset_color%}"
    done
  }

  # Show all 256 colors where the background is set to specific color
  function spectrum_bls() {
    for code in {000..255}; do
      print -P -- "$code: %{$BG[$code]%}$OSH_SPECTRUM_TEXT%{$reset_color%}"
    done
  }
fi
