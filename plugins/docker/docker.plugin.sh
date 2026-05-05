#! bash oh-my-bash.module
# Description: Aliases and utility functions for Docker
# Inspired by the oh-my-zsh docker plugin (https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/docker)

if ! _omb_util_command_exists docker; then
  return
fi

_omb_module_require completion:docker

# Build
alias dbl='docker build'

# Containers
alias dcin='docker container inspect'
alias dcls='docker container ls'
alias dclsa='docker container ls -a'
alias dlo='docker container logs'
alias dpo='docker container port'
alias dr='docker container run'
alias drit='docker container run -it'
alias drm='docker container rm'
alias drmf='docker container rm -f'
alias drs='docker container restart'
alias dst='docker container start'
alias dstp='docker container stop'
alias dsts='docker stats'
alias dtop='docker top'
alias dxc='docker container exec'
alias dxcit='docker container exec -it'

# Images
alias dib='docker image build'
alias dii='docker image inspect'
alias dils='docker image ls'
alias dipru='docker image prune -a'
alias dipu='docker image push'
alias dirm='docker image rm'
alias dit='docker image tag'
alias dpu='docker pull'

# Networks
alias dnc='docker network create'
alias dncn='docker network connect'
alias dndcn='docker network disconnect'
alias dni='docker network inspect'
alias dnls='docker network ls'
alias dnrm='docker network rm'

# Volumes
alias dvi='docker volume inspect'
alias dvls='docker volume ls'
alias dvprune='docker volume prune'

# General
alias dps='docker ps'
alias dpsa='docker ps -a'

# System
alias dsi='docker system info'
alias dsdf='docker system df'
alias dsp='docker system prune'
alias dspf='docker system prune -f'
alias dspa='docker system prune -a'

# Stop all running containers
function _omb_plugin_docker_stop_all {
  local -a ids
  ids=($(docker ps -q)) || return 1
  if [[ ${#ids[@]} -eq 0 ]]; then
    _omb_util_print '[oh-my-bash] docker: no running containers to stop' >&2
    return 0
  fi
  docker stop "${ids[@]}"
}
alias dsta='_omb_plugin_docker_stop_all'

# Remove all stopped containers (created, paused, exited, dead)
function _omb_plugin_docker_rm_stopped {
  local -a ids
  ids=($(docker ps -aq --filter status=created \
                          --filter status=paused \
                          --filter status=exited \
                          --filter status=dead)) || return 1
  if [[ ${#ids[@]} -eq 0 ]]; then
    _omb_util_print '[oh-my-bash] docker: no stopped containers to remove' >&2
    return 0
  fi
  docker rm "${ids[@]}"
}
alias drmst='_omb_plugin_docker_rm_stopped'

# Print the IP address of a container: dip <container>
function _omb_plugin_docker_ip {
  docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$@"
}
alias dip='_omb_plugin_docker_ip'
