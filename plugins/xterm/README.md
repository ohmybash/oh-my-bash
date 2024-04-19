### Plugin xterm

#### Description

This script automatically sets your xterm title with host and location information. It dynamically updates the title to reflect the current user, host, directory, and command being executed.

#### Source

You can find the original source of this script [here](https://github.com/Bash-it/bash-it/blob/bf2034d13d/plugins/available/xterm.plugin.bash).

#### Variables

- `PROMPT_CHAR` (optional): This variable is shared with powerline.
- `OMB_PLUGIN_XTERM_SHORT_TERM_LINE` (optional): Controls whether to shorten the directory name in the title.
- `OMB_PLUGIN_XTERM_SHORT_USER` (optional): Overrides the default user name.
- `OMB_PLUGIN_XTERM_SHORT_HOSTNAME` (optional): Overrides the default hostname.

#### Functions

1. **`_omb_plugin_xterm_set_title`**

   - Sets the xterm title with the provided string.

2. **`_omb_plugin_xterm_precmd_title`**

   - Updates the xterm title before executing a command.
   - Includes the user, host, directory, and prompt character.

3. **`_omb_plugin_xterm_preexec_title`**

   - Updates the xterm title after executing a command.
   - Includes the user, host, directory, and the first part of the executed command.

4. **`set_xterm_title`**
   - Manually sets the xterm title with the provided string.

#### Usage

1. **Installation:**

   - Add this script to your shell configuration file (e.g., `.bashrc`, `.bash_profile`).

2. **Customization:**

   - Modify the variables and functions as needed to fit your preferences.

3. **Execution:**
   - The xterm title will automatically update based on your commands and directory changes.
