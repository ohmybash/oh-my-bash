# aliases

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
