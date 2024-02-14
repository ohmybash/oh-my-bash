#! bash oh-my-bash.module

function _omb_completion_docker_compose_has_completion {
  local complete
  complete=$(complete -p docker-compose 2>/dev/null) && [[ $complete ]] || return 1

  unset -f _omb_completion_docker_compose_has_completion
  unset -f _omb_completion_docker_compose_try
  return 0
}

function _omb_completion_docker_compose_try {
  if [[ -s $1 ]]; then
    source "$1"
    _omb_completion_docker_compose_has_completion && return 0
  elif [[ -s $1.sh ]]; then
    source "$1.sh"
    _omb_completion_docker_compose_has_completion && return 0
  elif [[ -s $1.bash ]]; then
    source "$1.bash"
    _omb_completion_docker_compose_has_completion && return 0
  fi
  return 1
}

_omb_completion_docker_compose_has_completion && return 0

if _omb_util_function_exists _comp_load; then
  # bash-completion 2.12
  _comp_load -- docker-compose
  _omb_completion_docker_compose_has_completion && return 0
elif _omb_util_function_exists __load_completion; then
  # bash-completion <= 2.11
  __load_completion docker-compose
  _omb_completion_docker_compose_has_completion && return 0
fi

_omb_completion_docker_compose_try /usr/share/bash-completion/completions/docker-compose && return 0
_omb_completion_docker_compose_try /etc/bash_completion.d/docker-compose && return 0

unset -f _omb_completion_docker_compose_has_completion
unset -f _omb_completion_docker_compose_try
source "$OSH/completions/fallback/docker-compose.bash"
