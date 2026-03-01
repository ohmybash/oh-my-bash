#! bash oh-my-bash.module
#
# Kubernetes prompt helper for bash/zsh
# Displays current context and namespace
#
# Copyright 2020 Jon Mosco
#
#  Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# ---------------------------------------------------------------------------
#
# This file is a derivative work based on kube-ps1
# <https://github.com/jonmosco/kube-ps1>.
#
# ---------------------------------------------------------------------------
#
# Usage: add $(kube_ps1) to your PS1 or theme, and use
#   kubeon  / kubeoff  to toggle the prompt info.
#
# ---------------------------------------------------------------------------

# Debug
[[ -n ${DEBUG:-} ]] && set -x

# ---------------------------------------------------------------------------
# Public configuration variables (override in ~/.bashrc before loading OMB)
# ---------------------------------------------------------------------------
KUBE_PS1_BINARY="${KUBE_PS1_BINARY:-kubectl}"
KUBE_PS1_SYMBOL_ENABLE="${KUBE_PS1_SYMBOL_ENABLE:-true}"
KUBE_PS1_SYMBOL_PADDING="${KUBE_PS1_SYMBOL_PADDING:-false}"
KUBE_PS1_SYMBOL_COLOR="${KUBE_PS1_SYMBOL_COLOR:-blue}"
KUBE_PS1_SYMBOL_CUSTOM="${KUBE_PS1_SYMBOL_CUSTOM:-}"

KUBE_PS1_CTX_COLOR="${KUBE_PS1_CTX_COLOR:-red}"
KUBE_PS1_NS_COLOR="${KUBE_PS1_NS_COLOR:-cyan}"
KUBE_PS1_PREFIX_COLOR="${KUBE_PS1_PREFIX_COLOR:-}"
KUBE_PS1_SUFFIX_COLOR="${KUBE_PS1_SUFFIX_COLOR:-}"
KUBE_PS1_BG_COLOR="${KUBE_PS1_BG_COLOR:-}"

KUBE_PS1_NS_ENABLE="${KUBE_PS1_NS_ENABLE:-true}"
KUBE_PS1_CONTEXT_ENABLE="${KUBE_PS1_CONTEXT_ENABLE:-true}"
KUBE_PS1_PREFIX="${KUBE_PS1_PREFIX-(}"
KUBE_PS1_SEPARATOR="${KUBE_PS1_SEPARATOR-|}"
KUBE_PS1_DIVIDER="${KUBE_PS1_DIVIDER-:}"
KUBE_PS1_SUFFIX="${KUBE_PS1_SUFFIX-)}"

KUBE_PS1_HIDE_IF_NOCONTEXT="${KUBE_PS1_HIDE_IF_NOCONTEXT:-false}"

# Optional user-supplied functions to transform or color context/namespace
# KUBE_PS1_CLUSTER_FUNCTION=""
# KUBE_PS1_NAMESPACE_FUNCTION=""
# KUBE_PS1_CTX_COLOR_FUNCTION=""

# ---------------------------------------------------------------------------
# Internal state variables
# ---------------------------------------------------------------------------
_omb_plugin_kube_ps1_kubeconfig_cache="${KUBECONFIG}"
_omb_plugin_kube_ps1_disable_path="${HOME}/.kube/kube-ps1/disabled"
_omb_plugin_kube_ps1_last_time=0
_omb_plugin_kube_ps1_cfgfiles_read_cache=
_omb_plugin_kube_ps1_initialized=false

# Escape sequences for bash prompt
_KUBE_PS1_OPEN_ESC=$'\001'
_KUBE_PS1_CLOSE_ESC=$'\002'
_KUBE_PS1_DEFAULT_BG=$'\033[49m'
_KUBE_PS1_DEFAULT_FG=$'\033[39m'

# ---------------------------------------------------------------------------
# Colour helpers
# ---------------------------------------------------------------------------
_omb_plugin_kube_ps1_color_fg() {
  local code
  case "${1}" in
    black)   code=0 ;;
    red)     code=1 ;;
    green)   code=2 ;;
    yellow)  code=3 ;;
    blue)    code=4 ;;
    magenta) code=5 ;;
    cyan)    code=6 ;;
    white)   code=7 ;;
    [0-9]|[1-9][0-9]|[1][0-9][0-9]|[2][0-4][0-9]|[2][5][0-5]) code="${1}" ;;
    *) printf '%s' "${_KUBE_PS1_OPEN_ESC}${_KUBE_PS1_DEFAULT_FG}${_KUBE_PS1_CLOSE_ESC}"; return ;;
  esac

  local seq
  if tput setaf 1 &>/dev/null; then
    seq="$(tput setaf "${code}")"
  else
    seq="\033[38;5;${code}m"
  fi
  printf '%s' "${_KUBE_PS1_OPEN_ESC}${seq}${_KUBE_PS1_CLOSE_ESC}"
}

_omb_plugin_kube_ps1_color_bg() {
  local code
  case "${1}" in
    black)   code=0 ;;
    red)     code=1 ;;
    green)   code=2 ;;
    yellow)  code=3 ;;
    blue)    code=4 ;;
    magenta) code=5 ;;
    cyan)    code=6 ;;
    white)   code=7 ;;
    [0-9]|[1-9][0-9]|[1][0-9][0-9]|[2][0-4][0-9]|[2][5][0-5]) code="${1}" ;;
    *) printf '%s' "${_KUBE_PS1_OPEN_ESC}${_KUBE_PS1_DEFAULT_BG}${_KUBE_PS1_CLOSE_ESC}"; return ;;
  esac

  local seq
  if tput setab 1 &>/dev/null; then
    seq="$(tput setab "${code}")"
  else
    seq="\033[48;5;${code}m"
  fi
  printf '%s' "${_KUBE_PS1_OPEN_ESC}${seq}${_KUBE_PS1_CLOSE_ESC}"
}

# ---------------------------------------------------------------------------
# Symbol
# ---------------------------------------------------------------------------
_omb_plugin_kube_ps1_symbol() {
  [[ "${KUBE_PS1_SYMBOL_ENABLE}" == false ]] && return

  local reset_color="${_KUBE_PS1_OPEN_ESC}${_KUBE_PS1_DEFAULT_FG}${_KUBE_PS1_CLOSE_ESC}"
  local symbol

  case "${KUBE_PS1_SYMBOL_CUSTOM:-}" in
    img)
      symbol=$'\xE2\x98\xB8'  # ☸ (UTF-8 bytes for bash < 4)
      ;;
    k8s)
      symbol="$(_omb_plugin_kube_ps1_color_fg "${KUBE_PS1_SYMBOL_COLOR}")$'\Uf10fe'${reset_color}"
      ;;
    oc)
      symbol="$(_omb_plugin_kube_ps1_color_fg red)$'\ue7b7'${reset_color}"
      ;;
    *)
      # Use unicode helm symbol; fall back to UTF-8 bytes for old bash
      if ((BASH_VERSINFO[0] >= 4)) && [[ $'\u2388' != "\\u2388" ]]; then
        symbol="$(_omb_plugin_kube_ps1_color_fg "${KUBE_PS1_SYMBOL_COLOR}")"$'\u2388'"${reset_color}"
      else
        symbol=$'\xE2\x8E\x88'
      fi
      ;;
  esac

  if [[ "${KUBE_PS1_SYMBOL_PADDING}" == true ]]; then
    printf '%s ' "${symbol}"
  else
    printf '%s' "${symbol}"
  fi
}

# ---------------------------------------------------------------------------
# Config-file helpers
# ---------------------------------------------------------------------------
_omb_plugin_kube_ps1_split_config() {
  local IFS="$1"
  # Disable globbing so unquoted $2 only word-splits on IFS and does not
  # expand wildcards that may appear in KUBECONFIG paths.
  local _glob_state=$-
  set -f
  # shellcheck disable=SC2086  # intentional word-splitting on IFS
  printf '%s\n' $2
  # Restore globbing only if it was enabled before this call.
  [[ $_glob_state == *f* ]] || set +f
}

_omb_plugin_kube_ps1_file_newer_than() {
  local file="$1" check_time="$2" mtime
  if stat -c "%s" /dev/null &>/dev/null; then
    # GNU stat
    mtime=$(stat -L -c %Y "${file}")
  else
    # BSD stat (macOS)
    mtime=$(stat -L -f %m "${file}")
  fi
  (( mtime > check_time ))
}

# ---------------------------------------------------------------------------
# Context / namespace fetching
# ---------------------------------------------------------------------------
_omb_plugin_kube_ps1_get_context() {
  [[ "${KUBE_PS1_CONTEXT_ENABLE}" == true ]] || return
  KUBE_PS1_CONTEXT="$(${KUBE_PS1_BINARY} config current-context 2>/dev/null)"
  KUBE_PS1_CONTEXT="${KUBE_PS1_CONTEXT:-N/A}"
  if [[ -n "${KUBE_PS1_CLUSTER_FUNCTION:-}" ]]; then
    KUBE_PS1_CONTEXT="$("${KUBE_PS1_CLUSTER_FUNCTION}" "${KUBE_PS1_CONTEXT}")"
  fi
}

_omb_plugin_kube_ps1_get_ns() {
  [[ "${KUBE_PS1_NS_ENABLE}" == true ]] || return
  KUBE_PS1_NAMESPACE="$(${KUBE_PS1_BINARY} config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)"
  KUBE_PS1_NAMESPACE="${KUBE_PS1_NAMESPACE:-default}"
  if [[ -n "${KUBE_PS1_NAMESPACE_FUNCTION:-}" ]]; then
    KUBE_PS1_NAMESPACE="$("${KUBE_PS1_NAMESPACE_FUNCTION}" "${KUBE_PS1_NAMESPACE}")"
  fi
}

_omb_plugin_kube_ps1_get_context_ns() {
  if ((BASH_VERSINFO[0] >= 4 && BASH_VERSINFO[1] >= 2)); then
    _omb_plugin_kube_ps1_last_time=$(printf '%(%s)T')
  else
    _omb_plugin_kube_ps1_last_time=$(date +%s)
  fi

  KUBE_PS1_CONTEXT="${KUBE_PS1_CONTEXT:-N/A}"
  KUBE_PS1_NAMESPACE="${KUBE_PS1_NAMESPACE:-default}"

  # Build cache of readable config files
  local conf
  _omb_plugin_kube_ps1_cfgfiles_read_cache=
  while IFS= read -r conf; do
    [[ -r "${conf}" ]] && _omb_plugin_kube_ps1_cfgfiles_read_cache+=":${conf}"
  done < <(_omb_plugin_kube_ps1_split_config : "${KUBECONFIG:-${HOME}/.kube/config}")

  _omb_plugin_kube_ps1_get_context
  _omb_plugin_kube_ps1_get_ns
}

# ---------------------------------------------------------------------------
# PS1 appender – injects the kube segment into PS1 after the theme sets it.
# Registered lazily on first PROMPT_COMMAND run so it is always last.
# Skips injection when PS1 already contains $(kube_ps1) literally, meaning
# the user has chosen to embed it manually in their PS1 or theme.
# ---------------------------------------------------------------------------
_omb_plugin_kube_ps1_ps1_append() {
  [[ "${KUBE_PS1_ENABLED:-on}" == "off" ]] && return
  # If the user already has $(kube_ps1) in their PS1, do not inject again.
  [[ "${PS1}" == *'$(kube_ps1)'* ]] && return
  local seg
  seg="$(kube_ps1)" || return
  [[ -z "$seg" ]] && return
  # Prepend the segment so it appears before the theme's own prompt text.
  # Skip the separator space if the segment already ends with a newline.
  if [[ "${seg}" == *$'\n' ]]; then
    PS1="${seg}${PS1}"
  else
    PS1="${seg} ${PS1}"
  fi
}

# ---------------------------------------------------------------------------
# PROMPT_COMMAND hook – updates KUBE_PS1_CONTEXT / KUBE_PS1_NAMESPACE
# ---------------------------------------------------------------------------
_omb_plugin_kube_ps1_prompt_update() {
  local return_code=$?

  # Lazy first-run: register ps1_append AFTER the theme has been added to
  # _omb_util_prompt_command, so it always executes last.
  # _omb_util_prompt_command_hook uses an index loop, so the newly registered
  # function is invoked in the same prompt-render cycle it is added.
  if [[ "${_omb_plugin_kube_ps1_initialized}" == false ]]; then
    _omb_plugin_kube_ps1_initialized=true
    _omb_util_add_prompt_command _omb_plugin_kube_ps1_ps1_append
  fi

  [[ "${KUBE_PS1_ENABLED:-on}" == "off" ]] && return $return_code

  if ! _omb_util_command_exists "${KUBE_PS1_BINARY}"; then
    KUBE_PS1_CONTEXT="BINARY-N/A"
    KUBE_PS1_NAMESPACE="N/A"
    return $return_code
  fi

  if [[ "${KUBECONFIG}" != "${_omb_plugin_kube_ps1_kubeconfig_cache}" ]]; then
    _omb_plugin_kube_ps1_kubeconfig_cache="${KUBECONFIG}"
    _omb_plugin_kube_ps1_get_context_ns
    return $return_code
  fi

  local conf config_file_cache=
  while IFS= read -r conf; do
    [[ -r "${conf}" ]] || continue
    config_file_cache+=":${conf}"
    if _omb_plugin_kube_ps1_file_newer_than "${conf}" \
        "${_omb_plugin_kube_ps1_last_time}"; then
      _omb_plugin_kube_ps1_get_context_ns
      return $return_code
    fi
  done < <(_omb_plugin_kube_ps1_split_config : "${KUBECONFIG:-${HOME}/.kube/config}")

  if [[ "${config_file_cache}" != "${_omb_plugin_kube_ps1_cfgfiles_read_cache}" ]]; then
    _omb_plugin_kube_ps1_get_context_ns
  fi

  return $return_code
}

# Register the hook
_omb_util_add_prompt_command _omb_plugin_kube_ps1_prompt_update

# ---------------------------------------------------------------------------
# Honour a persistent "disabled" marker on startup
# ---------------------------------------------------------------------------
[[ -f "${_omb_plugin_kube_ps1_disable_path}" ]] && KUBE_PS1_ENABLED=off

# ---------------------------------------------------------------------------
# kubeon / kubeoff
# ---------------------------------------------------------------------------
_omb_plugin_kube_ps1_kubeon_usage() {
  cat <<'EOF'
Toggle kube-ps1 prompt on

Usage: kubeon [-g | --global] [-h | --help]

With no arguments, turn on kube-ps1 status for this shell instance (default).

  -g --global  turn on kube-ps1 status globally
  -h --help    print this message
EOF
}

_omb_plugin_kube_ps1_kubeoff_usage() {
  cat <<'EOF'
Toggle kube-ps1 prompt off

Usage: kubeoff [-g | --global] [-h | --help]

With no arguments, turn off kube-ps1 status for this shell instance (default).

  -g --global  turn off kube-ps1 status globally
  -h --help    print this message
EOF
}

kubeon() {
  case "${1:-}" in
    -h|--help)
      _omb_plugin_kube_ps1_kubeon_usage ;;
    -g|--global)
      rm -f -- "${_omb_plugin_kube_ps1_disable_path}"
      KUBE_PS1_ENABLED=on ;;
    "")
      KUBE_PS1_ENABLED=on ;;
    *)
      printf 'error: unrecognized flag %s\n\n' "${1}" >&2
      _omb_plugin_kube_ps1_kubeon_usage
      return 1 ;;
  esac
}

kubeoff() {
  case "${1:-}" in
    -h|--help)
      _omb_plugin_kube_ps1_kubeoff_usage ;;
    -g|--global)
      mkdir -p -- "$(dirname "${_omb_plugin_kube_ps1_disable_path}")"
      touch -- "${_omb_plugin_kube_ps1_disable_path}"
      KUBE_PS1_ENABLED=off ;;
    "")
      KUBE_PS1_ENABLED=off ;;
    *)
      printf 'error: unrecognized flag %s\n\n' "${1}" >&2
      _omb_plugin_kube_ps1_kubeoff_usage
      return 1 ;;
  esac
}

# ---------------------------------------------------------------------------
# kube_ps1 – the function to embed in PS1
#
# Usage in a theme or ~/.bashrc:
#   PS1='... $(kube_ps1) ...'
# ---------------------------------------------------------------------------
kube_ps1() {
  [[ "${KUBE_PS1_ENABLED:-on}" == "off" ]] && return
  [[ -z "${KUBE_PS1_CONTEXT:-}" ]] && [[ "${KUBE_PS1_CONTEXT_ENABLE}" == true ]] && return
  [[ "${KUBE_PS1_CONTEXT:-}" == "N/A" ]] && [[ "${KUBE_PS1_HIDE_IF_NOCONTEXT}" == true ]] && return

  local reset_color="${_KUBE_PS1_OPEN_ESC}${_KUBE_PS1_DEFAULT_FG}${_KUBE_PS1_CLOSE_ESC}"
  if [[ -n "${KUBE_PS1_BG_COLOR:-}" ]]; then
    reset_color="${_KUBE_PS1_OPEN_ESC}${_KUBE_PS1_DEFAULT_FG}${_KUBE_PS1_DEFAULT_BG}${_KUBE_PS1_CLOSE_ESC}"
  fi

  local kube_ps1=

  # Background colour
  [[ -n "${KUBE_PS1_BG_COLOR:-}" ]] && \
    kube_ps1+="$(_omb_plugin_kube_ps1_color_bg "${KUBE_PS1_BG_COLOR}")"

  # Prefix
  if [[ -z "${KUBE_PS1_PREFIX_COLOR:-}" ]]; then
    kube_ps1+="${KUBE_PS1_PREFIX}"
  else
    kube_ps1+="$(_omb_plugin_kube_ps1_color_fg "${KUBE_PS1_PREFIX_COLOR}")${KUBE_PS1_PREFIX}${reset_color}"
  fi

  # Symbol
  kube_ps1+="$(_omb_plugin_kube_ps1_symbol)"

  if [[ -n "${KUBE_PS1_SEPARATOR}" ]] && [[ "${KUBE_PS1_SYMBOL_ENABLE}" == true ]]; then
    kube_ps1+="${KUBE_PS1_SEPARATOR}"
  fi

  # Context
  if [[ "${KUBE_PS1_CONTEXT_ENABLE}" == true ]]; then
    local ctx_color="${KUBE_PS1_CTX_COLOR:-red}"
    if [[ -n "${KUBE_PS1_CTX_COLOR_FUNCTION:-}" ]]; then
      ctx_color="$("${KUBE_PS1_CTX_COLOR_FUNCTION}" "${KUBE_PS1_CONTEXT}")"
    fi
    kube_ps1+="$(_omb_plugin_kube_ps1_color_fg "${ctx_color}")${KUBE_PS1_CONTEXT}${reset_color}"
  fi

  # Namespace
  if [[ "${KUBE_PS1_NS_ENABLE}" == true ]]; then
    if [[ -n "${KUBE_PS1_DIVIDER}" ]] && [[ "${KUBE_PS1_CONTEXT_ENABLE}" == true ]]; then
      kube_ps1+="${KUBE_PS1_DIVIDER}"
    fi
    kube_ps1+="$(_omb_plugin_kube_ps1_color_fg "${KUBE_PS1_NS_COLOR:-cyan}")${KUBE_PS1_NAMESPACE}${reset_color}"
  fi

  # Suffix
  if [[ -z "${KUBE_PS1_SUFFIX_COLOR:-}" ]]; then
    kube_ps1+="${KUBE_PS1_SUFFIX}"
  else
    kube_ps1+="$(_omb_plugin_kube_ps1_color_fg "${KUBE_PS1_SUFFIX_COLOR}")${KUBE_PS1_SUFFIX}${reset_color}"
  fi

  # Close background colour
  [[ -n "${KUBE_PS1_BG_COLOR:-}" ]] && \
    kube_ps1+="${_KUBE_PS1_OPEN_ESC}${_KUBE_PS1_DEFAULT_BG}${_KUBE_PS1_CLOSE_ESC}"

  printf '%s' "${kube_ps1}"
}
