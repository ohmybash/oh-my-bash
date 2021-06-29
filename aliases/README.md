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
