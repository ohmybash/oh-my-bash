#! bash oh-my-bash.module

if ! declare -F __sdkman_build_version_csv &>/dev/null; then
  # @fn __sdkman_build_version_csv
  #   Copyright 2021 Marco Vermeulen.
  #   Licensed under the Apache License, Version 2.0 (the "License");
  #
  #   This function was taken from "main/bash/sdkman-list.sh @
  #   sdkman/sdkman-cli".
  #   https://github.com/sdkman/sdkman-cli/blob/19e5c081297d6a8d1ce8a8b54631bb3f8e8e861b/src/main/bash/sdkman-list.sh#L51
  function __sdkman_build_version_csv() {
    local candidate=$1
    local versions_csv=""
    if [[ -d ${SDKMAN_CANDIDATES_DIR}/${candidate} ]]; then
      for version in $(find "${SDKMAN_CANDIDATES_DIR}/${candidate}" -maxdepth 1 -mindepth 1 \( -type l -o -type d \) -exec basename '{}' \; | sort -r); do
        if [[ $version != 'current' ]]; then
          versions_csv=${version},${versions_csv}
        fi
      done
      versions_csv=${versions_csv%?}
    fi
    echo "$versions_csv"
  }
fi

_omb_completion_sdkman()
{
  local cur=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=()

  if ((COMP_CWORD == 1)); then
    COMPREPLY=( $(compgen -W "install uninstall rm list ls use current outdated version default selfupdate broadcast offline help flush" -- "$cur") )
  elif ((COMP_CWORD == 2)); then
    case ${COMP_WORDS[COMP_CWORD-1]} in
      "install" | "uninstall" | "rm" | "list" | "ls" | "use" | "current" | "outdated" )
        local candidates
        candidates=$(echo "${SDKMAN_CANDIDATES_CSV}" | tr ',' ' ')
        COMPREPLY=( $(compgen -W "$candidates" -- "$cur") )
        ;;
      "offline" )
        COMPREPLY=( $(compgen -W "enable disable" -- "$cur") )
        ;;
      "selfupdate" )
        COMPREPLY=( $(compgen -W "force" -P "[" -S "]" -- "$cur") )
        ;;
      "flush" )
        COMPREPLY=( $(compgen -W "candidates broadcast archives temp" -- "$cur") )
        ;;
      *)
        ;;
    esac
  elif ((COMP_CWORD == 3)); then
    case ${COMP_WORDS[COMP_CWORD-2]} in
      "install" | "uninstall" | "rm" | "use" | "default" )
        local candidate_versions
        _omb_completion_sdkman__candidate_versions "${COMP_WORDS[COMP_CWORD-1]}"
        COMPREPLY=( $(compgen -W "$candidate_versions" -- "$cur") )
        ;;
      *)
        ;;
    esac
  fi

  return 0
}

function _omb_completion_sdkman__candidate_versions {
  local local_versions=$(_omb_completion_sdkman__cleanup_local_versions "$1")
  if [[ $SDKMAN_OFFLINE_MODE = "true" ]]; then
    candidate_versions=$local_versions
  else
    local online_versions="$(curl -s "${SDKMAN_SERVICE}/candidates/$1" | tr ',' ' ')"
    candidate_versions="$(echo $online_versions $local_versions |sort | uniq ) "
  fi

}

function _omb_completion_sdkman__cleanup_local_versions {
  __sdkman_build_version_csv "$1"
  tr ',' ' ' <<< "$CSV"
}

complete -F _omb_completion_sdkman sdk
