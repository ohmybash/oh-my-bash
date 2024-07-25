# Aliases `general`

## Basic Commands

| Alias          | Command                                | Description                                                                        |
|----------------|----------------------------------------|------------------------------------------------------------------------------------|
| `c`            | `clear`                                | Clear terminal display                                                             |
| `cic`          | `bind "set completion-ignore-case on"` | Make tab-completion case-insensitive                                               |
| `cp`           | `cp -iv`                               | `cp` with confirmation on overwriting (option `-v` is added if supported)          |
| `fix_stty`     | `stty sane`                            | Restore terminal settings when screwed up                                          |
| `fix_term`     | `echo -e "\033c"`                      | Reset the conosle.  Similar to the reset command                                   |
| `less`         | `less -FSRXc`                          | Preferred `less` implementation                                                    |
| `ll`           | `ls -lAFh`                             | Preferred `ls` implementation                                                      |
| `mkdir`        | `mkdir -pv`                            | Recursive `mkdir` if the target does not exist (option `-v` is added if supported) |
| `mv`           | `mv -iv`                               | `mv` with confirmation on overwriting (option `-v` is added if supported)          |
| `nano`         | `nano -W`                              | (option `-W` is added if supported)                                                |
| `path`         | `echo -e ${PATH//:/\\n}`               | Echo all executable Paths                                                          |
| `show_options` | `shopt`                                | display bash options settings                                                      |
| `src`          | `source ~/.bashrc`                     | Reload `.bashrc` file                                                              |
| `wget`         | `wget -c`                              | Preferred `wget` implementation (resume download)                                  |
