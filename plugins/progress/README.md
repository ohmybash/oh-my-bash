# Using the Progress Bar Script

## Description

This script provides a simple progress bar TUI for the terminal platform. It allows you to visualize the progress of a task being executed in your shell script.

## Usage

You can use the function `progress` from the interactive settings with Oh My
Bash.  The function handles printing of the progress bar.

1. **Enable plugin:**

  - Add the plugin name `progress` in the `plugins` array in `~/.bashrc`.

  ```shell
  # bashrc

  plugins=(... progress)
  ```

2. **Invoke `progress` Function:**
   - Within a shell function, call the `progress` function whenever you want to display the progress bar.
   - Pass two parameters to the `progress` function:
     - `PARAM_PROGRESS`: The progress percentage (0-100) of the task.
     - `PARAM_STATUS`: Optional. A status message to display alongside the progress bar.

   ```bash
   # Example usage:
   progress 25 "Processing data..."  # Displays a 25% progress bar with the status "Processing data..."
   ```

To change the delay of the progress bar, please overwrite the `delay` function.

```bash
# Example: change the delay to 0.1 sec
function delay { sleep 0.1; }
```

_⚠️ if you want to add only the plugin and not Oh My Bash, you can copy the file
`progress.plugin.sh` to a place you like and source it in `~/.basrhc` (for
interactive uses) or in a shell script (for a standalone shell program).  You
may instead copy and paste the functions directly into a script file, in which
case the plugin will not receive updates and possible errors will have to be
solved by you_


## Example

```bash
# bashrc

function example {
  # Example: Your code for the shell function here:  Invoke the progress
  # function to display the progress bar as your function progresses.  This
  # displays a 25% progress bar with the status "Processing data...":
  progress 25 "Processing data..."
```

This will visually represent the progress of your function's execution in the
terminal. Adjust the `progress` function calls according to the progress of
your task.
