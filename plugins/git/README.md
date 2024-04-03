
# Git Plugin Guide for Oh My Bash

## This guide provides detailed instructions on how to use the Git plugin for Oh My Bash.
This plugin adds useful functions and aliases to enhance the experience of working with Git in the terminal.

# Installation
Make sure you have Oh My Bash installed on your system. If you don't, follow the installation instructions.
Activate the Git plugin by editing your `.bashrc` or `.bash_profile` file and adding `git` to the list of plugins in Oh My Bash configuration.

```bash
plugins=(... git)
```
Save the file and restart your terminal for the changes to take effect.

# Usage
Once you have installed and activated the Git plugin, you can start using the provided functions and aliases. Here are some examples of how to use them:

## Functions

```bash
current_branch(): Displays the name of the current branch.
```

```bash
$ current_branch
```

```bash
current_repository(): Shows the list of remotes configured for the current repository.
```

```bash
$ current_repository
```

```bash
work_in_progress(): Warns if the current branch is marked as work in progress (WIP).
```

```bash
$ work_in_progress
```

## Aliases
Aliases simplify common Git operations. Here are some examples:

- `g`: Alias for the `git` command.
- `ga`: Adds files to the staging area.

```bash
$ ga file.txt
```

- `gaa`: Adds all files to the staging area.

```bash
$ gaa
```

- `gap`: Adds files to the staging area interactively.

```bash
$ gap
```

and many more...

To use an alias, simply type the alias in your terminal followed by any necessary arguments.
