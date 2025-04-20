# Random

This is a special Oh-My-Bash theme value.  When `random` is specified to
`OSH_THEME`, Oh My Bash randomly selects and loads an existing theme.

## Variables

The list of theme names from which the theme is selected can be specified to
the array `OMB_THEME_RANDOM_CANDIDATES` in `~/.bashrc`.  When the candidate
list is not supplied, a theme is selected from all available themes in
`$OSH_CUSTOM` and `$OSH`.

The theme names that the `random` theme should not select can be sorted in the
array `OMB_THEME_RANDOM_IGNORED` in `~/.bashrc`.

After initialization, the currently selected theme name is stored in the
variable `OMB_THEME_RANDOM_SELECTED`:

```console
[oh-my-bash] Random theme 'font' loaded...
$ echo "$OMB_THEME_RANDOM_SELECTED"
font
```
