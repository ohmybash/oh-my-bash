#! bash oh-my-bash.module

SCM_THEME_PROMPT_PREFIX="${_omb_prompt_bold_red}"
SCM_THEME_PROMPT_SUFFIX="${_omb_prompt_normal}"
SCM_THEME_PROMPT_DIRTY=" ${_omb_prompt_bold_red}✗${_omb_prompt_normal}"
SCM_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓${_omb_prompt_normal}"
SCM_GIT_CHAR=""

# ICONS =======================================================================

icon_start="${_omb_prompt_bold_purple}╭─${_omb_prompt_normal}"
icon_middle="${_omb_prompt_bold_purple}├─${_omb_prompt_normal}"
icon_end="${_omb_prompt_bold_purple}╰─${_omb_prompt_normal}"
icon_prompt="${_omb_prompt_bold_purple}>_${_omb_prompt_normal}"

# FUNCTIONS ===================================================================

scm_prompt() {
  printf 'on %s' "$(scm_prompt_info)"
}

distrobox_instance() {
  if [[ -n ${DISTROBOX_NAME:-} ]]; then
    printf '%s' "$DISTROBOX_NAME"
    return
  fi
  if [[ -n ${DBX_CONTAINER_NAME:-} ]]; then
    printf '%s' "$DBX_CONTAINER_NAME"
    return
  fi

  if [[ -r /run/.containerenv ]]; then
    awk -F= '$1=="name"{gsub(/"/,"",$2); print $2}' /run/.containerenv 2>/dev/null && return
  fi

  if [[ -f /.dockerenv ]]; then
    hostname
    return
  fi

  return 1
}

segment_distro() {
  local dbx_name="$1"
  [[ -r /etc/os-release ]] || return 0

  local NAME VERSION_ID
  . /etc/os-release

  local name="${NAME:-Linux}"
  local ver="${VERSION_ID:-}"

  name="${name%% *}"

  local dbx_norm name_norm ver_norm
  dbx_norm=${dbx_name//[^[:alnum:]]/}; dbx_norm=${dbx_norm,,}
  name_norm=${name//[^[:alnum:]]/};    name_norm=${name_norm,,}
  ver_norm=${ver//[^[:alnum:]]/};      ver_norm=${ver_norm,,}

  local out=""
  if [[ -n $dbx_name && $dbx_norm == *"$name_norm"* ]]; then
    if [[ -n $ver && $dbx_norm != *"$ver_norm"* ]]; then
      out="${_omb_prompt_bold_teal}${ver}${_omb_prompt_normal}"
    fi
  else
    if [[ -n $ver ]]; then
      out="${_omb_prompt_bold_teal}${name} ${ver}${_omb_prompt_normal}"
    else
      out="${_omb_prompt_bold_teal}${name}${_omb_prompt_normal}"
    fi
  fi

  [[ -n $out ]] && printf '%s' "$out"
}

# PROMPT OUTPUT ===============================================================

_omb_theme_PROMPT_COMMAND() {
  local seg_user="${_omb_prompt_bold_navy}\u${_omb_prompt_normal}"
  local seg_host="${_omb_prompt_bold_olive}\h${_omb_prompt_normal}"

  local venv_segment=""
  if [[ -n ${VIRTUAL_ENV} ]]; then
    venv_segment=" ${_omb_prompt_bold_purple}(venv)${_omb_prompt_normal}"
  fi

  local seg_path="${_omb_prompt_bold_green}\w${_omb_prompt_normal}"

  # Headline
  local line_header="${icon_start}${seg_user}@${seg_host}:${venv_segment}${seg_path}\n"

  # Distrobox (optional)
  local dbx_name=$(distrobox_instance 2>/dev/null)
  local line_distrobox=""
  if [[ -n $dbx_name ]]; then
    local seg_distro=$(segment_distro "$dbx_name")
    line_distrobox="${icon_middle}${_omb_prompt_bold_purple}distrobox:${_omb_prompt_normal} ${_omb_prompt_bold_teal}${dbx_name}${_omb_prompt_normal}"
    [[ -n $seg_distro ]] && line_distrobox+=" ${seg_distro}"
    line_distrobox+=$'\n'
  fi

  # VCS/Git (optional)
  local scm_char
  scm_char=$(scm_char)
  local line_vcs=""
  if [[ $scm_char != "$SCM_NONE_CHAR" ]]; then
    line_vcs="${icon_middle}$(scm_prompt)\n"
  fi

  # Prompt
  local line_prompt="${icon_end}${icon_prompt}"

  PS1="${line_header}${line_distrobox}${line_vcs}${line_prompt}"
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
