# Chezmoi plugin

The chezmoi plugin defines a number of useful aliases for you. [Consult the complete list](./chezmoi.plugin.sh)

## List of aliases

| Alias | Command                | Description                                                                                                                                                             |
| ----- | ---------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| cz    | 'chezmoi'              | Manage your dotfiles across multiple diverse machines, securely                                                                                                         |
| cza   | 'chezmoi add'          | Add targets to the source state. If any target is already in the source state, then its source state is replaced with its current state in the destination directory.   |
| czcd  | 'chezmoi cd'           | cd's into the chezmoi source directory                                                                                                                                  |
| cze   | 'chezmoi edit'         | Edit the source state of targets, which must be files or symlinks. If no targets are given then the working tree of the source directory is opened.                     |
| czea  | 'chezmoi edit --apply' | Apply target immediately after editing. Ignored if there are no targets.                                                                                                |
| czra  | 'chezmoi re-add'       | Re-add modified files in the target state, preserving any encrypted\_ attributes. chezmoi will not overwrite templates, and all entries that are not files are ignored. |
