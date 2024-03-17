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

----

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

- `emerge` (Portage Enoch Merge) ... `em`, `es`, `esync`, `eb`, `er`, `emfu`, `ecd`, `ecp`, `elip`
- `cave` (Paludis Cave) ... `cave`, `cr`, `cui`, `cs`, `cli`
- `apt` (Advanced Packaging Tool) ... `apt`, `aptfu`, `apti`, `apts`, `aptr`, `aptar`, `aptli`
- `dpkg` (Debian Package) ... `dpkg`
- `nala` (Nala APT Wrapper) ... `nala`, `nalaf`, `nalau`, `nalafu`, `nalai`, `nalar`, `nalaa`, `nalah`, `nalal`, `nalas`, `nalav`

The command to use to call these package manager can be specified in the variable `OMB_ALIAS_PACKAGE_MANAGER_SUDO`.  By default, `sudo` is used when the current use is not root and the command `sudo` is available.

```bash
# Use sudo to run the package manager
OMB_ALIAS_PACKAGE_MANAGER_SUDO=sudo

# Do not use sudo but directly run the package manager
OMB_ALIAS_PACKAGE_MANAGER_SUDO=
```

### Emerge Package Manager

| Alias   | Command                                          | Description                                                                                                                      |
| ------- | ------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------- |
| `em`    | `sudo emerge`                                    | Emerge is the definitive command-line interface to the Portage system.                                                           |
| `es`    | `sudo emerge --search`                           | Searches for matches of the supplied string in the ebuild repository.                                                            |
| `esync` | `sudo emerge --sync`                             | Updates repositories, for which auto-sync, sync-type and sync-uri attributes are set in repos.conf.                              |
| `eb`    | `sudo ebuild`                                    | An ebuild must be, at a minimum, a valid Portage package directory name without a version or category, such as portage or python.|
| `er`    | `sudo emerge -c`                                 | Cleans the system by removing packages that are not associated with explicitly merged packages.                                  |
| `emfu`  | `sudo emerge --sync && sudo emerge -uDN @world`  | Emerge update & upgrade system.                                                                                                  |
| `eu`    | `sudo emerge -uDN @world`                        | Emerge upgrade system.                                                                                                           |
| `ei`    | `sudo emerge --info`                             | Emerge display information.                                                                                                      |
| `ep`    | `sudo emerge -p`                                 | Emerge display what would have been installed.                                                                                   |
| `e1`    | `sudo emerge -1`                                 | Emerge merge without adding the packages to the world file.                                                                      |
| `ecp`   | `sudo eclean-pkg -d`                             | Cleans binary packages.                                                                                                          |
| `elip`  | `sudo eix-installed -a`                          | Lists all installed programs.                                                                                                    |
| `ecd`   | `sudo eclean-dist -d`                            | Cleans repository source files.                                                                                                  |
| `eq`    | `sudo equery`                                    | Package query tool.                                                                                                              |
| `ers`   | `sudo emerge -c`                                 | (Deprecated, retained for backward compatibility. Use `er` instead.)                                                             |

### Paludis Package Manager (`cave`)

| Alias  | Command               | Description                                                                                             |
| ------ | --------------------- | ------------------------------------------------------------------------------------------------------- |
| `cave` | `sudo cave`           | The Other Package Manager.                                                                              |
| `cr`   | `sudo cave resolve`   | Solve the dependencies and print out the results. Pass the `-x` option to actually install the package. |
| `cui`  | `sudo cave uninstall` | Uninstall a package.                                                                                    |
| `cs`   | `sudo cave show`      | Show the dependencies of a package.                                                                     |
| `cli`  | `sudo cave list`      | List all available Packages.                                                                            |

### APT Package Manager

| Alias   | Command                                                                                           | Description                                                                                                          |
| ------- | ------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| `apt`   | `sudo apt`                                                                                        | Advanced Packaging Tool.                                                                                             |
| `aptfu` | `sudo apt update -y && sudo apt upgrade -y && sudo apt dist-upgrade -y && sudo apt autoremove -y` | Automatically update package lists, fully upgrade all packages, and remove any orphaned packages.                    |
| `apti`  | `sudo apt install -y`                                                                             | Performs the requested action on one or more packages specified via regex(7), glob(7) or exact match.                |
| `apts`  | `sudo apt-cache search`                                                                           | Search can be used to search for the given regex(7) term(s) in the list of available packages and display matches.   |
| `aptr`  | `sudo apt remove -y`                                                                              | Performs the requested action on one or more packages specified via regex(7), glob(7) or exact match.                |
| `aptar` | `sudo apt autoremove -y`                                                                          | Remove packages that were automatically installed for dependencies but are now no longer needed.                     |
| `aptli` | `sudo apt list`                                                                                   | List is somewhat similar to dpkg-query --list in that it can display a list of packages satisfying certain criteria. |

### Debian Package Manager (`dpkg`)

| Alias  | Command     | Description                 |
| ------ | ----------- | --------------------------- |
| `dpkg` | `sudo dpkg` | Package manager for Debian. |

### Nala Package Manager

| Alias   | Command                   | Description                                                                                              |
| ------- | ------------------------- | -------------------------------------------------------------------------------------------------------- |
| `nala`  | `sudo nala`               | Nala is a prettier front-end for libapt-pkg, doubles as --help.                                          |
| `nalaf` | `sudo nala fetch`         | Fetch fast mirrors to improve download speed.                                                            |
| `nalau` | `sudo nala update`        | Update the list of available packages.                                                                   |
| `nalafu`| `sudo nala upgrade -y`    | The equivalent of apt update && apt full-upgrade --auto-remove.                                          |
| `nalai` | `sudo nala install -y`    | Takes multiple packages as arguments and will install all of them.                                       |
| `nalar` | `sudo nala remove -y`     | Remove or purge packages that are no longer needed.                                                      |
| `nalaa` | `sudo nala autoremove -y` | Automatically remove or purge any packages that are no longer needed.                                    |
| `nalah` | `sudo nala history`       | Nala history with no subcommands will show a summary of all transactions made.                           |
| `nalal` | `sudo nala list`          | List all packages or only packages based on the provided name, glob or regex. By default will only glob. |
| `nalas` | `sudo nala search`        | Search package names and descriptions using a word, regex or glob.                                       |
| `nalav` | `sudo nala show`          | Show information about a package such as the name, version, dependencies etc.                            |

----

## alias:terraform

| Alias    | Command                      |
| -------- | ---------------------------- |
| `t`      | `terraform`                  |
| `tinit`  | `terraform init`             |
| `tplan`  | `terraform plan`             |
| `tapply` | `terraform apply`            |
| `tfmt`   | `terraform fmt`              |

