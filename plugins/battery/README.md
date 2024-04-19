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
- **Returns:**
  - Battery percentage as an integer.

### 4. `battery_charge`

- **Description:** Presents a graphical representation of the battery charge using ASCII characters.
- **Returns:**
  - Graphical representation of the battery charge.

## Usage

1. Ensure the plugin file is properly integrated into your `.bashrc` or `.bash_profile`.
2. Utilize the provided functions to monitor battery status and information directly in your terminal.

```bash
# Check if AC adapter is connected
ac_adapter_connected

# Retrieve battery percentage
battery_percentage

# Visualize battery charge graphically
battery_charge
```

## Dependencies

This plugin relies on several utilities for retrieving battery information:

- `upower`: Primary tool for battery information retrieval.
- `acpi`, `pmset`, `ioreg`, `WMIC`: Fallback options for battery information retrieval.
- `/sys/class/power_supply/`: Fallback option for battery information retrieval.

```

```
