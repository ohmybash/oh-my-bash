# Git Plugin

The git plugin defines a number of useful shell functions to improve your Git workflow by simplifying common Git commands and providing useful shortcuts. [Consult the complete list](git.plugin.sh#L34).

To use it, add `git` to the plugins array in your bashrc file.

```bash
plugins=(... git)
```

## Shell Functions

- `current_branch`: Get the name of the current branch.
- `current_repository`: Get the list of remotes for the current repository.
- `work_in_progress`: Warn if the current branch is a work in progress.
- `git_develop_branch`: Check for develop and similarly named branches.
- `git_main_branch`: Check if main exists and use instead of master.
