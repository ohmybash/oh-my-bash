# Battery Plugin for Oh My Bash

## Overview

This custom plugin for Oh My Bash enhances your terminal experience by providing functions to monitor and display battery status and information. 

## Usage
This line might start to look like this its location is usually here: `.bashrc` `.bash_profile`.
```shell
plugins = (git bundler osx rake ruby)
```
_⚠️ if you want to only add the plugin(s) and not oh-my-bash you can copy it and paste it directly into .bashrc or .bash_profile. by doing this the plugins will not receive updates, the errors will have to be solved by you_

## Dependencies

This plugin relies on several utilities for retrieving battery information:
- `upower`: Primary tool for battery information retrieval.
- `acpi`, `pmset`, `ioreg`, `WMIC`: Fallback options for battery information retrieval.
- `/sys/class/power_supply/`: Fallback option for battery information retrieval.
