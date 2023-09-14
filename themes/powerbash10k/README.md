# powerbash10k theme

Simple colorful terminal prompt theme (inspired by powerlevel10k zsh theme, based on Brainy theme).

## Features

### Prompt Segments

- Username & Hostname
- Current Directory
- SCM Information
- Battery Charge
- Clock
- Command duration
- [Todo.txt](https://github.com/ginatrapani/todo.txt-cli) status
- Ruby Environment
- Python Environment
- Exit Code

### Others

- Indicator for cached `sudo` credential
- Indicator for ssh login
- `pb10k` command for showing/hiding various prompt segments on-the-fly

## Configuration

Various prompt segments can be shown/hidden or modified according to your choice. There are two ways for doing that:

1. On-the-fly using `pb10k` command
2. Theme Environment Variables

### On-the-fly using `pb10k` command

This theme provides a command for showing/hiding prompt segments.

`pb10k show <segment>`

`pb10k hide <segment>`

Tab-completion for this command is enabled by default.

Configuration specified by this command will only be applied to current and subsequent child shells.

### Theme Environment Variables

This is used for permanent settings that apply to all terminal sessions. You have to define the value of specific theme variables in your `bashrc` (or equivalent) file.

The name of the variables are listed below along with their default values.

#### User Information

Indicator for cached `sudo` credential (see `sudo` manpage for more information):

`THEME_SHOW_SUDO=true`

Hide user info for local user (show only in SSH sessions):
`__PB10K_PROMPT_LOCAL_USER_INFO=false`

#### SCM Information

Information about SCM repository status:

`THEME_SHOW_SCM=true`

#### Ruby Environment

Ruby environment version information:

`THEME_SHOW_RUBY=false`

#### Python Environment

Python environment version information:

`THEME_SHOW_PYTHON=false`

#### ToDo.txt status

[Todo.txt](https://github.com/ginatrapani/todo.txt-cli) status:

`THEME_SHOW_TODO=false`

#### Clock

`THEME_SHOW_CLOCK=true`

`THEME_CLOCK_COLOR=$bold_cyan`

Format of the clock (see `date` manpage for more information):

`THEME_CLOCK_FORMAT="%H:%M:%S"`

#### Battery Charge

Battery charge percentage:

`THEME_SHOW_BATTERY=false`

#### Exit Code

Exit code of the last command:

`THEME_SHOW_EXITCODE=true`

## Prompt Segments Order

Currently available prompt segments are:

- battery
- char
- clock
- cmd_duration
- dir
- exitcode
- python
- ruby
- scm
- todo
- user_info

Three environment variables can be defined to rearrange the segments order. The default values are:

`__PB10K_TOP_LEFT="dir scm"`

`__PB10K_TOP_RIGHT="exitcode cmd_duration user_info python ruby todo clock battery"`

`__PB10K_BOTTOM="char"`
