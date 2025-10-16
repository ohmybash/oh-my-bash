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

segment_distro() {
  local dbx_name="$1"
  [[ -r /etc/os-release ]] || return 0

  local NAME VERSION_ID

  while IFS='=' read -r key value; do
    value="${value#\"}"
    value="${value%\"}"
    value="${value#\'}"
    value="${value%\'}"

    case "${key}" in
      NAME)
        NAME="${value}"
        ;;
      VERSION_ID)
        VERSION_ID="${value}"
        ;;
    esac
  done < <(grep -E '^(NAME|VERSION_ID)=' /etc/os-release 2>/dev/null)

  local name="${NAME:-Linux}"
  local ver="${VERSION_ID:-}"

  name="${name%% *}"

  local dbx_norm name_norm ver_norm
  dbx_norm="${dbx_name//[^[:alnum:]]/}"
  dbx_norm="${dbx_norm,,}"
  name_norm="${name//[^[:alnum:]]/}"
  name_norm="${name_norm,,}"
  ver_norm="${ver//[^[:alnum:]]/}"
  ver_norm="${ver_norm,,}"

  local out=""

  if [[ -n ${dbx_name} && ${dbx_norm} == *"${name_norm}"* ]]; then
    if [[ -n ${ver} && ${dbx_norm} != *"${ver_norm}"* ]]; then
      out="${_omb_prompt_bold_teal}${ver}${_omb_prompt_normal}"
    fi
  else
    if [[ -n ${ver} ]]; then
      out="${_omb_prompt_bold_teal}${name} ${ver}${_omb_prompt_normal}"
    else
      out="${_omb_prompt_bold_teal}${name}${_omb_prompt_normal}"
    fi
  fi

  [[ -n ${out} ]] && printf '%s' "${out}"
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
  local container_name=""
  local detection_method=""

  if [[ -n ${DISTROBOX_NAME:-} ]]; then
    container_name="${DISTROBOX_NAME}"
    detection_method="DISTROBOX_NAME"
  elif [[ -n ${DBX_CONTAINER_NAME:-} ]]; then
    container_name="${DBX_CONTAINER_NAME}"
    detection_method="DBX_CONTAINER_NAME"
  elif [[ -r /run/.containerenv ]]; then
    container_name=$(awk -F= '$1=="name"{gsub(/"/,"",$2); print $2}' /run/.containerenv 2>/dev/null)
    detection_method="containerenv"
  elif [[ -f /.dockerenv ]]; then
    container_name=$(hostname 2>/dev/null)
    detection_method="dockerenv"
  fi

  local line_container=""
  if [[ -n ${container_name} ]]; then
    local seg_distro=""
    seg_distro=$(segment_distro "${container_name}")

    line_container="${icon_middle}${_omb_prompt_bold_purple}container:${_omb_prompt_normal} ${_omb_prompt_bold_teal}${container_name}${_omb_prompt_normal}"

    if [[ -n ${seg_distro} ]]; then
      line_container+=" ${seg_distro}"
    fi

    line_container+=$'\n'
  fi

  # VCS/Git (optional)
  local scm_char
  scm_char=$(scm_char)
  local line_vcs=""

  if [[ ${scm_char} != "${SCM_NONE_CHAR}" ]]; then
    line_vcs="${icon_middle}$(scm_prompt)\n"
  fi

  # Prompt
  local line_prompt="${icon_end}${icon_prompt}"
  PS1="${line_header}${line_container}${line_vcs}${line_prompt}"
}

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
