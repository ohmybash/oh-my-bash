# aliases

## alias:debian

Shorted aliases for most used Debian specific commands.
To activate it, add `debian` to `plugins(...)` in your `.bashrc` file:

`plugins=(... debian)`

### Basic Commands

| Alias  | Command                               |
| ------ | ------------------------------------- |
| `apup` | `sudo apt update`                     |
| `apug` | `sudo apt upgrade`                    |
| `apuu` | `sudo apt update && sudo apt upgrade` |
| `apfu` | `sudo apt full-upgrade`               |
| `apin` | `sudo apt install`                    |
| `apri` | `sudo apt install --reinstall `       |
| `aprm` | `sudo apt remove`                     |
| `apur` | `sudo apt purge`                      |
| `apse` | `apt search`                          |
| `apdl` | `apt-get download`                    |

### APT Maintainance & Diagnostic Commands

| Alias   | Command                                                |
| ------- | ------------------------------------------------------ |
| `apar`  | `sudo apt autoremove`                                  |
| `apcl`  | `sudo apt-get autoclean`                               |
| `apesr` | `sudo apt edit-sources`                                |
| `apsh`  | `apt show`                                             |
| `aphst` | <code>cat /var/log/apt/history.log &#124; less </code> |
| `drcf`  | `sudo dpkg-reconfigure`                                |

### APT Source & Building Commands

| Alias  | Command              |
| ------ | -------------------- |
| `apsc` | `apt-get source`     |
| `apbd` | `sudo apt build-deb` |

### Debian's update-\* commands

| Alias   | Command                    |
| ------- | -------------------------- |
| `upgrb` | `sudo update-grub`         |
| `uirfs` | `sudo update-initramfs -u` |

## alias:Docker

|  Alias    |  Command                      |  Description                                                                             |
| :------   | :---------------------------- | :--------------------------------------------------------------------------------------- |
| `dbl`     | `docker build`                | Build an image from a Dockerfile                                                         |
| `dcin`    | `docker container inspect`    | Display detailed information on one or more containers                                   |
| `dcls`    | `docker container ls`         | List all the running docker containers                                                   |
| `dclsa`   | `docker container ls -a`      | List all running and stopped containers                                                  |
| `dib`     | `docker image build`          | Build an image from a Dockerfile (same as docker build)                                  |
| `dii`     | `docker image inspect`        | Display detailed information on one or more images                                       |
| `dils`    | `docker image ls`             | List docker images                                                                       |
| `dipu`    | `docker image push`           | Push an image or repository to a remote registry                                         |
| `dirm`    | `docker image rm`             | Remove one or more images                                                                |
| `dit`     | `docker image tag`            | Add a name and tag to a particular image                                                 |
| `dlo`     | `docker container logs`       | Fetch the logs of a docker container                                                     |
| `dnc`     | `docker network create`       | Create a new network                                                                     |
| `dncn`    | `docker network connect`      | Connect a container to a network                                                         |
| `dndcn`   | `docker network disconnect`   | Disconnect a container from a network                                                    |
| `dni`     | `docker network inspect`      | Return information about one or more networks                                            |
| `dnls`    | `docker network ls`           | List all networks the engine daemon knows about, including those spanning multiple hosts |
| `dnrm`    | `docker network rm`           | Remove one or more networks                                                              |
| `dpo`     | `docker container port`       | List port mappings or a specific mapping for the container                               |
| `dpu`     | `docker pull`                 | Pull an image or a repository from a registry                                            |
| `dr`      | `docker container run`        | Create a new container and start it using the specified command                          |
| `drit`    | `docker container run -it`    | Create a new container and start it in an interactive shell                              |
| `drm`     | `docker container rm`         | Remove the specified container(s)                                                        |
| `drm!`    | `docker container rm -f`      | Force the removal of a running container (uses SIGKILL)                                  |
| `dst`     | `docker container start`      | Start one or more stopped containers                                                     |
| `drs`     | `docker container restart`    | Restart one or more containersa                                                          |
| `dsta`    | `docker stop $(docker ps -q)` | Stop all running containers                                                              |
| `dstp`    | `docker container stop`       | Stop one or more running containers                                                      |
| `dtop`    | `docker top`                  | Display the running processes of a container                                             |
| `dvi`     | `docker volume inspect`       | Display detailed information about one or more volumes                                   |
| `dvls`    | `docker volume ls`            | List all the volumes known to docker                                                     |
| `dvprune` | `docker volume prune`         | Cleanup dangling volumes                                                                 |
| `dxc`     | `docker container exec`       | Run a new command in a running container                                                 |
| `dxcit`   | `docker container exec -it`   | Run a new command in a running container in an interactive shell                         |

----

## alias:package-manager

This plugin provides the set of aliases that can be used to control package managers.  Here is the list of the supported aliases for each package manager.  You can find the details of each alias in the source [`package-manager.aliases.bash`](package-manager.aliases.bash).

- `emerge` (Portage Enoch Merge) ... `em`, `es`, `esync`, `eb`, `er`, `ers`, `emfu`, `elip`
- `cave` (Paludis Cave) ... `cave`, `cr`, `cui`, `cs`, `cli`
- `apt` (Advanced Packaging Tool) ... `apt`, `aptfu`, `apti`, `apts`, `aptr`, `aptar`, `aptli`
- `dpkg` (Debian Package) ... `dpkg`

The command to use to call these package manager can be specified in the variable `OMB_ALIAS_PACKAGE_MANAGER_SUDO`.  By default, `sudo` is used when the current use is not root and the command `sudo` is available.

```bash
# Use sudo to run the package manager
OMB_ALIAS_PACKAGE_MANAGER_SUDO=sudo

# Do not use sudo but directly run the package manager
OMB_ALIAS_PACKAGE_MANAGER_SUDO=
```

## alias:terraform

| Alias    | Command                      |
| -------- | ---------------------------- |
| `t`      | `terraform`                  |
| `tinit`  | `terraform init`             |
| `tplan`  | `terraform plan`             |
| `tapply` | `terraform apply`            |
| `tfmt`   | `terraform fmt`              |
