#! bash oh-my-bash.module

# This theme loads another randomly-chosen theme.

## @var[out] _omb_init_themes
function _omb_theme_random__list_available_themes {
  _omb_init_themes=()

  local theme_files
  _omb_util_glob_expand theme_files '"$OSH"/themes/*/*.theme.sh'
  ((${#theme_files[@]})) || return 1

  local -a themes=() index theme
  for index in "${!theme_files[@]}"; do
    theme=${theme_files[index]##*/}
    theme=${theme%.theme.sh}
    [[ ${theme_files[index]} == */"$theme"/"$theme".theme.sh ]] || continue

    _omb_util_array_contains themes "$theme" ||
      themes+=("$theme")
  done
  ((${#themes[@]})) || return 1

  # Remove ignored themes from the list
  local theme index
  for theme in random "${OMB_THEME_RANDOM_IGNORED[@]}"; do
    for index in "${!themes[@]}"; do
      [[ ${themes[index]} == "$theme" ]] &&
        unset -v 'themes[index]'
    done
  done
  ((${#themes[@]})) || return 1
  _omb_init_themes=("${themes[@]}")
}
_omb_theme_random__list_available_themes

if ((${#_omb_init_themes[@]})); then
  OMB_THEME_RANDOM_SELECTED=${_omb_init_themes[RANDOM%${#_omb_init_themes[@]}]}
  _omb_module_require_theme "$OMB_THEME_RANDOM_SELECTED"
  printf '%s\n' "[oh-my-bash] Random theme '$OMB_THEME_RANDOM_SELECTED' loaded..."
fi
unset -v _omb_init_themes
