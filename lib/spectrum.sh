#! bash oh-my-bash.module
# A script to make using 256 colors in bash less painful.
# P.C. Shyamshankar <sykora@lucentbeing.com>
# Copied from http://github.com/sykora/etc/blob/master/zsh/functions/spectrum/

_omb_module_require lib:omb-deprecate
_omb_module_require lib:omb-prompt-colors

# typeset in bash does not have associative arrays, declare does in bash 4.0+
# https://stackoverflow.com/a/6047948

# This library only works for BASH 4.x to keep the minimum compatibility for macOS.
# shellcheck disable=SC2034
if
  # shellcheck disable=SC2168
  if ((_omb_bash_version >= 40200)); then
    declare -gA _omb_spectrum_fx=()
    declare -gA _omb_spectrum_fg=()
    declare -gA _omb_spectrum_bg=()
    declare -gA FX FG BG
  elif ((_omb_bash_version >= 40000)) && ! local _omb_local_test 2>/dev/null; then
    declare -A _omb_spectrum_fx=()
    declare -A _omb_spectrum_fg=()
    declare -A _omb_spectrum_bg=()
    declare -A FX FG BG
  else
    false
  fi
then
  function _omb_spectrum__initialize() {
    _omb_spectrum_fx=(
      [reset]=$'\e[00m'
      [bold]=$'\e[01m'       [no-bold]=$'\e[22m'
      [italic]=$'\e[03m'     [no-italic]=$'\e[23m'
      [underline]=$'\e[04m'  [no-underline]=$'\e[24m'
      [blink]=$'\e[05m'      [no-blink]=$'\e[25m'
      [reverse]=$'\e[07m'    [no-reverse]=$'\e[27m'
    )
    local color
    for color in {000..255}; do
      _omb_spectrum_fg[$color]=$'\e[38;5;'${color}'m'
      _omb_spectrum_bg[$color]=$'\e[48;5;'${color}'m'
    done
  }
  _omb_spectrum__initialize

  _omb_deprecate_const 20000 _RED "$_omb_term_brown"   "${_omb_deprecate_msg_please_use/'%s'/_omb_term_brown}"
  _omb_deprecate_const 20000 _NC  "$_omb_term_reset" "${_omb_deprecate_msg_please_use/'%s'/_omb_term_reset}"
  function _omb_spectrum__deprecate() {
    local key
    for key in "${!_omb_spectrum_fx[@]}"; do FX[$key]=${_omb_spectrum_fx[$key]}; done
    for key in "${!_omb_spectrum_fg[@]}"; do FG[$key]=${_omb_spectrum_fg[$key]}; done
    for key in "${!_omb_spectrum_bg[@]}"; do BG[$key]=${_omb_spectrum_bg[$key]}; done
  }
  _omb_spectrum__deprecate
fi

OSH_SPECTRUM_TEXT=${OSH_SPECTRUM_TEXT:-Arma virumque cano Troiae qui primus ab oris}

# Show all 256 colors with color number
function spectrum_ls() {
  local code
  for code in {000..255}; do
    printf '%s: \e[38;5;%sm%s%s\n' "$code" "$code" "$OSH_SPECTRUM_TEXT" "$_omb_term_reset"
  done
}

# Show all 256 colors where the background is set to specific color
function spectrum_bls() {
  local code
  for code in {000..255}; do
    printf '%s: \e[48;5;%sm%s%s\n' "$code" "$code" "$OSH_SPECTRUM_TEXT" "$_omb_term_reset"
  done
}
