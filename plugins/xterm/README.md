# Xterm Plugin

## Description

This script automatically sets your xterm title with host and location information. It dynamically updates the title to reflect the current user, host, directory, and command being executed.

## Source

You can find the original source of this script [here](https://github.com/Bash-it/bash-it/blob/bf2034d13d/plugins/available/xterm.plugin.bash).

## Variables

- `PROMPT_CHAR` (optional): This variable is shared with powerline.
- `OMB_PLUGIN_XTERM_SHORT_TERM_LINE` (optional): Controls whether to shorten the directory name in the title.
- `OMB_PLUGIN_XTERM_SHORT_USER` (optional): Overrides the default user name.
- `OMB_PLUGIN_XTERM_SHORT_HOSTNAME` (optional): Overrides the default hostname.

## Functions

1. **`set_xterm_title`**
   - Sets the xterm title with the provided string.

## Usage

1. **Enable plugin:**

  - Add the plugin name `xterm` in the `plugins` array in `~/.bashrc`.

  ```shell
  # bashrc

  plugins=(... xterm)
  ```

2. **Customization:**

  - Modify the variables and functions as needed to fit your preferences.

The xterm title will be automatically updated based on your commands and directory changes.

_⚠️ if you want to add only this plugin and not Oh My Bash, you can copy the
file `xterm.plugin.bash` in a place you like and edit the file to comment out
the line `_omb_module_require plugin:bash-preexec`.  Then, source
`xterm.plugin.bash` in `~/.basrhc` (for interactive uses) or in a shell script
(for a standalone shell program).  To make the xterm title be automatically
updated, you also need to get a copy of `bash-preexec.sh` (a not up-to-date one
is found in the repository of Oh My Bash at `tools/bash-preexec.sh`) and source
it as well.  You may instead copy and paste the functions directly into a
script file, in which case the plugin will not receive updates and possible
errors will have to be solved by you_

## Dependencies

This plugin relies on `bash-preexec.sh` for the preexec and precmd hooks.
