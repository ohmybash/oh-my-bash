#! bash oh-my-bash.module

# This theme loads another randomly-chosen theme.

## @var[out] _omb_init_themes
function _omb_theme_random__list_available_themes {
  # When OMB_THEME_RANDOM_CANDIDATES is set, we use it as the theme list
  # available for the random theme.
  if [[ ${OMB_THEME_RANDOM_CANDIDATES[@]+set} ]]; then
    _omb_init_themes=("${OMB_THEME_RANDOM_CANDIDATES[@]}")
    return 0
  fi

  _omb_init_themes=()

  local theme_files
  _omb_util_glob_expand theme_files '{"$OSH_CUSTOM"{,/themes},"$OSH"/themes}/*/*.theme.{bash,sh}'
  ((${#theme_files[@]})) || return 1

  local -a exclude_themes=(random)
  if ((${#OMB_THEME_RANDOM_IGNORED[@]})); then
    exclude_themes+=("${OMB_THEME_RANDOM_IGNORED[@]}")
  fi

  local -a themes=() index theme
  for index in "${!theme_files[@]}"; do
    theme=${theme_files[index]##*/}
    theme=${theme%.theme.sh}

    # Check the filename format
    [[ ${theme_files[index]} == */"$theme"/"$theme".theme.sh ]] ||
      [[ ${theme_files[index]} == */"$theme"/"$theme".theme.bash ]] ||
      continue

    # Exclude ignored themes from the list
    _omb_util_array_contains exclude_themes "$theme" && continue

    # Remove duplicates
    _omb_util_array_contains themes "$theme" && continue

    themes+=("$theme")
  done
  ((${#themes[@]})) || return 1

  _omb_init_themes=("${themes[@]}")
}
_omb_theme_random__list_available_themes

if ((${#_omb_init_themes[@]})); then
  OMB_THEME_RANDOM_SELECTED=${_omb_init_themes[RANDOM%${#_omb_init_themes[@]}]}
  _omb_module_require_theme "$OMB_THEME_RANDOM_SELECTED" &&
    printf '%s\n' "[oh-my-bash] Random theme '$OMB_THEME_RANDOM_SELECTED' loaded..."
fi
unset -v _omb_init_themes
