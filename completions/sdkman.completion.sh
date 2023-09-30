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
    local candidate versions_csv
    candidate="$1"
    versions_csv=""
    if [[ -d "${SDKMAN_CANDIDATES_DIR}/${candidate}" ]]; then
      for version in $(find "${SDKMAN_CANDIDATES_DIR}/${candidate}" -maxdepth 1 -mindepth 1 \( -type l -o -type d \) -exec basename '{}' \; | sort -r); do
        if [[ "$version" != 'current' ]]; then
          versions_csv="${version},${versions_csv}"
        fi
      done
      versions_csv=${versions_csv%?}
    fi
    echo "$versions_csv"
  }
fi

_omb_completion_sdkman()
{
  local CANDIDATES
  local CANDIDATE_VERSIONS

  COMPREPLY=()

  if [ $COMP_CWORD -eq 1 ]; then
    COMPREPLY=( $(compgen -W "install uninstall rm list ls use current outdated version default selfupdate broadcast offline help flush" -- ${COMP_WORDS[COMP_CWORD]}) )
  elif [ $COMP_CWORD -eq 2 ]; then
    case "${COMP_WORDS[COMP_CWORD-1]}" in
      "install" | "uninstall" | "rm" | "list" | "ls" | "use" | "current" | "outdated" )
        CANDIDATES=$(echo "${SDKMAN_CANDIDATES_CSV}" | tr ',' ' ')
        COMPREPLY=( $(compgen -W "$CANDIDATES" -- ${COMP_WORDS[COMP_CWORD]}) )
        ;;
      "offline" )
        COMPREPLY=( $(compgen -W "enable disable" -- ${COMP_WORDS[COMP_CWORD]}) )
        ;;
      "selfupdate" )
        COMPREPLY=( $(compgen -W "force" -P "[" -S "]" -- ${COMP_WORDS[COMP_CWORD]}) )
        ;;
      "flush" )
        COMPREPLY=( $(compgen -W "candidates broadcast archives temp" -- ${COMP_WORDS[COMP_CWORD]}) )
        ;;
      *)
        ;;
    esac
  elif [ $COMP_CWORD -eq 3 ]; then
    case "${COMP_WORDS[COMP_CWORD-2]}" in
      "install" | "uninstall" | "rm" | "use" | "default" )
        _omb_completion_sdkman__candidate_versions ${COMP_WORDS[COMP_CWORD-1]}
        COMPREPLY=( $(compgen -W "$CANDIDATE_VERSIONS" -- ${COMP_WORDS[COMP_CWORD]}) )
        ;;
      *)
        ;;
    esac
  fi

  return 0
}

function _omb_completion_sdkman__candidate_versions {

  CANDIDATE_LOCAL_VERSIONS=$(_omb_completion_sdkman__cleanup_local_versions $1)
  if [ "$SDKMAN_OFFLINE_MODE" = "true" ]; then
    CANDIDATE_VERSIONS=$CANDIDATE_LOCAL_VERSIONS
  else
    CANDIDATE_ONLINE_VERSIONS="$(curl -s "${SDKMAN_SERVICE}/candidates/$1" | tr ',' ' ')"
    CANDIDATE_VERSIONS="$(echo $CANDIDATE_ONLINE_VERSIONS $CANDIDATE_LOCAL_VERSIONS |sort | uniq ) "
  fi

}

function _omb_completion_sdkman__cleanup_local_versions {
  __sdkman_build_version_csv $1
  echo $CSV | tr ',' ' '

}

complete -F _omb_completion_sdkman sdk
