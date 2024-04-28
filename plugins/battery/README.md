# Battery Plugin for Oh My Bash

## Overview

This custom plugin for Oh My Bash enhances your terminal experience by providing functions to monitor and display battery status and information.

## Functions

### 1. `ac_adapter_connected`

- **Description:** Checks if the AC adapter is currently connected.
- **Returns:**
  - `0` if the adapter is connected.
  - Non-zero exit status otherwise.

### 2. `ac_adapter_disconnected`

- **Description:** Checks if the AC adapter is currently disconnected.
- **Returns:**
  - `0` if the adapter is disconnected.
  - Non-zero exit status otherwise.

### 3. `battery_percentage`

- **Description:** Retrieves and displays the current battery charge as a percentage of full (100%).
- **Standard Output:**
  - Battery percentage as an integer.

### 4. `battery_charge`

- **Description:** Presents a graphical representation of the battery charge using ASCII characters.
- **Stanard Output:**
  - Graphical representation of the battery charge.

## Usage

Add the plugin name `battery` in the `plugins` array in `~/.bashrc`.

```shell
# bashrc

plugins=(... battery)
```

You can use the functions from the interactive settings with Oh My Bash.

_⚠️ if you want to add only the plugin and not Oh My Bash, you can copy the file
`battery.plugin.sh` and `lib/utils.sh` to a place you like and source them in
`~/.basrhc` (for interactive uses) or in a shell script (for a standalone shell
program).  You may instead copy and paste the functions directly into a script
file, in which case the plugin will not receive updates and possible errors
will have to be solved by you_

## Dependencies

This plugin relies on several utilities for retrieving battery information:

- `upower`: Primary tool for battery information retrieval.
- `acpi`, `pmset`, `ioreg`, `WMIC`: Fallback options for battery information retrieval.
- `/sys/class/power_supply/`: Fallback option for battery information retrieval.

This plugin file also depends on the following module in Oh My Bash:

- `lib/utils.sh`
