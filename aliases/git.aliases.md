# Aliases: `git`

This adds various aliases for [git](https://git-scm.com/).

## General Git Commands

- `g`: Shortcut for `git`.
- `ga`: Shortcut for `git add`. Adds specified files to the staging area.
- `gaa`: Shortcut for `git add --all`. Adds all changes, including untracked files, to the staging area.
- `gc`: Shortcut for `git commit`. Commits changes to the repository.
- `gca`: Shortcut for `git commit --all`. Commits all changes to the repository.
- `gcmsg`: Shortcut for `git commit --message`. Commits changes with a specified message.
- `gd`: Shortcut for `git diff`. Shows changes between commits, commit and working tree, etc.
- `gdca`: Shortcut for `git diff --cached`. Shows changes between staged and last commit.
- `gf`: Shortcut for `git fetch`. Downloads objects and refs from another repository.
- `gg`: Shortcut for `git gui citool`. Launches Git GUI.
- `gl`: Shortcut for `git pull`. Fetches from and integrates with another repository or a local branch.
- `gpr`: Shortcut for `git pull --rebase`. Fetches and rebases changes from another repository.
- `gp`: Shortcut for `git push`. Pushes changes to a remote repository.
- `gs`: Shortcut for `git status`. Shows the working tree status.

## Branching and Merging

- `gcb`: Shortcut for `git checkout -b`. Creates a new branch and switches to it.
- `gco`: Shortcut for `git checkout`. Switches branches or restores working tree files.
- `gm`: Shortcut for `git merge`. Joins two or more development histories together.
- `grb`: Shortcut for `git rebase`. Reapplies commits on top of another base tip.
- `grbi`: Shortcut for `git rebase --interactive`. Reapplies commits interactively.
- `grbd`: Shortcut for `git rebase develop`. Reapplies commits onto the develop branch.
- `gsw`: Shortcut for `git switch`. Switches branches.

## Tagging

- `gta`: Shortcut for `git tag --annotate`. Creates an annotated tag.
- `gts`: Shortcut for `git tag --sign`. Creates a signed tag.
- `gtv`: Shortcut for `git tag`. Lists tags.

## Miscellaneous

- `gclean`: Shortcut for `git clean`. Removes untracked files from the working tree.
- `gunwip`: Undo last commit if marked as work in progress.
- `gignore`: Ignores changes to tracked files.
- `gunignore`: Stops ignoring changes to tracked files.
- `gcount`: Shows commit count by author.
- `gk`: Opens Git GUI.
- `gke`: Opens extended Git GUI.

## Usage Example

To add all changes and commit with a message, you can use:

```bash
gaa && gcmsg "Your commit message"
```
