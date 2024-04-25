### Using the Progress Bar Script

#### Description

This script provides a simple progress bar TUI for the terminal platform. It allows you to visualize the progress of a task being executed in your shell script.

#### Usage

1. **Copy Functions:**

   - Copy the `delay` and `progress` functions directly into your shell script.

2. **Invoke `progress` Function:**
   - Call the `progress` function within your script to display the progress bar.

#### Steps

1. **Copy Functions:**

   - Copy the `delay` and `progress` functions from the script provided into your own shell script. These functions handle the delay and printing of the progress bar.

2. **Invoke `progress` Function:**

   - Within your script, call the `progress` function whenever you want to display the progress bar.
   - Pass two parameters to the `progress` function:
     - `PARAM_PROGRESS`: The progress percentage (0-100) of the task.
     - `PARAM_STATUS`: Optional. A status message to display alongside the progress bar.

   ```bash
   # Example usage:
   progress 25 "Processing data..."  # Displays a 25% progress bar with the status "Processing data..."
   ```

#### Example

```bash
#!/bin/bash

# Copy the delay and progress functions here

# Your script logic here
# Invoke the progress function to display the progress bar as your script progresses
# Example:
progress 25 "Processing data..."  # Display a 25% progress bar with the status "Processing data..."
```

This will visually represent the progress of your script's execution in the terminal. Adjust the `progress` function calls according to the progress of your task.
