# docker plugin

Add [oh-my-bash](https://ohmybash.github.io) integration with [Docker](https://www.docker.com/), providing aliases and utility functions for common Docker workflows. Inspired by the [oh-my-zsh docker plugin](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/docker).

## Installation

1. [Install Docker](https://docs.docker.com/get-docker/).

2. Enable the plugin by adding it to your oh-my-bash `plugins` definition in `~/.bashrc`.
    ```sh
    plugins=(docker)
    ```

3. Optionally, enable Docker tab completions by adding it to your `completions` definition:
    ```sh
    completions=(docker)
    ```

## Aliases

### Build

| Alias  | Command               | Description                            |
|--------|-----------------------|----------------------------------------|
| `dbl`  | `docker build`        | Build an image from a Dockerfile       |

### Containers

| Alias   | Command                      | Description                                          |
|---------|------------------------------|------------------------------------------------------|
| `dcin`  | `docker container inspect`   | Display detailed info on one or more containers      |
| `dcls`  | `docker container ls`        | List running containers                              |
| `dclsa` | `docker container ls -a`     | List all containers (running and stopped)            |
| `dlo`   | `docker container logs`      | Fetch the logs of a container                        |
| `dpo`   | `docker container port`      | List port mappings for a container                   |
| `dr`    | `docker container run`       | Create and start a container                         |
| `drit`  | `docker container run -it`   | Create and start a container interactively           |
| `drm`   | `docker container rm`        | Remove one or more containers                        |
| `drmf`  | `docker container rm -f`     | Force-remove a running container                     |
| `drs`   | `docker container restart`   | Restart one or more containers                       |
| `dst`   | `docker container start`     | Start one or more stopped containers                 |
| `dstp`  | `docker container stop`      | Stop one or more running containers                  |
| `dsts`  | `docker stats`               | Display real-time container resource usage           |
| `dtop`  | `docker top`                 | Display the running processes of a container         |
| `dxc`   | `docker container exec`      | Run a command in a running container                 |
| `dxcit` | `docker container exec -it`  | Run an interactive command in a running container    |

### Images

| Alias    | Command                  | Description                                      |
|----------|--------------------------|--------------------------------------------------|
| `dib`    | `docker image build`     | Build an image from a Dockerfile                 |
| `dii`    | `docker image inspect`   | Display detailed info on one or more images      |
| `dils`   | `docker image ls`        | List images                                      |
| `dipru`  | `docker image prune -a`  | Remove all unused images                         |
| `dipu`   | `docker image push`      | Push an image to a registry                      |
| `dirm`   | `docker image rm`        | Remove one or more images                        |
| `dit`    | `docker image tag`       | Tag an image                                     |
| `dpu`    | `docker pull`            | Pull an image from a registry                    |

### Networks

| Alias   | Command                       | Description                            |
|---------|-------------------------------|----------------------------------------|
| `dnc`   | `docker network create`       | Create a network                       |
| `dncn`  | `docker network connect`      | Connect a container to a network       |
| `dndcn` | `docker network disconnect`   | Disconnect a container from a network  |
| `dni`   | `docker network inspect`      | Display detailed info on a network     |
| `dnls`  | `docker network ls`           | List networks                          |
| `dnrm`  | `docker network rm`           | Remove one or more networks            |

### Volumes

| Alias     | Command                | Description                         |
|-----------|------------------------|-------------------------------------|
| `dvi`     | `docker volume inspect`| Display detailed info on a volume   |
| `dvls`    | `docker volume ls`     | List volumes                        |
| `dvprune` | `docker volume prune`  | Remove unused volumes               |

### General

| Alias  | Command        | Description                                |
|--------|----------------|--------------------------------------------|
| `dps`  | `docker ps`    | List running containers                    |
| `dpsa` | `docker ps -a` | List all containers                        |

### System

| Alias   | Command                    | Description                                 |
|---------|----------------------------|---------------------------------------------|
| `dsi`   | `docker system info`       | Display system-wide information             |
| `dsdf`  | `docker system df`         | Show Docker disk usage                      |
| `dsp`   | `docker system prune`      | Remove unused data (with confirmation)      |
| `dspf`  | `docker system prune -f`   | Remove unused data (no confirmation prompt) |
| `dspa`  | `docker system prune -a`   | Remove all unused data including images     |

## Utility functions

| Alias   | Description                                                      |
|---------|------------------------------------------------------------------|
| `dsta`  | Stop all running containers                                      |
| `drmst` | Remove all stopped containers                                    |
| `dip`   | Print the IP address of a container: `dip <container>`          |

## Usage examples

```bash
# Start an interactive Ubuntu container and remove it on exit
drit --rm ubuntu bash

# Tail logs of a running container
dlo -f my-container

# Get the IP address of a container
dip my-container

# Stop all running containers
dsta

# Clean up stopped containers and dangling images
drmst && dsp
```
