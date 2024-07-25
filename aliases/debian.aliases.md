# Aliases `debian`

Shorted aliases for most used Debian specific commands.
To activate it, add `debian` to `aliases=(...)` in your `.bashrc` file:

```bash
aliases=(... debian)`
```

## Basic Commands

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

## APT Maintainance & Diagnostic Commands

| Alias   | Command                                                |
| ------- | ------------------------------------------------------ |
| `apar`  | `sudo apt autoremove`                                  |
| `apcl`  | `sudo apt-get autoclean`                               |
| `apesr` | `sudo apt edit-sources`                                |
| `apsh`  | `apt show`                                             |
| `aphst` | <code>cat /var/log/apt/history.log &#124; less </code> |
| `drcf`  | `sudo dpkg-reconfigure`                                |

## APT Source & Building Commands

| Alias  | Command              |
| ------ | -------------------- |
| `apsc` | `apt-get source`     |
| `apbd` | `sudo apt build-deb` |

## Debian's update-\* commands

| Alias   | Command                    |
| ------- | -------------------------- |
| `upgrb` | `sudo update-grub`         |
| `uirfs` | `sudo update-initramfs -u` |
