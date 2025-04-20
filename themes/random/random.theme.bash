#! bash oh-my-bash.module

# This theme loads another randomly-chosen theme.

## @var[out] _omb_init_files
function _omb_theme_random__list_available_themes {
  _omb_util_glob_expand _omb_init_files '"$OSH"/themes/*/*.theme.sh'

  # Remove ignored themes from the list
  local theme index
  for theme in random "${OMB_THEME_RANDOM_IGNORED[@]}"; do
    for index in "${!_omb_init_files[@]}"; do
      [[ ${_omb_init_files[index]} == */"$theme"/* ]] &&
        unset -v '_omb_init_files[index]'
    done
  done
  _omb_init_files=("${_omb_init_files[@]}")
}
_omb_theme_random__list_available_themes

if ((${#_omb_init_files[@]})); then
  _omb_init_file=${_omb_init_files[RANDOM%${#_omb_init_files[@]}]}
  source "$_omb_init_file"
  OMB_THEME_RANDOM_SELECTED=${_omb_init_file##*/}
  OMB_THEME_RANDOM_SELECTED=${OMB_THEME_RANDOM_SELECTED%.theme.bash}
  OMB_THEME_RANDOM_SELECTED=${OMB_THEME_RANDOM_SELECTED%.theme.sh}
  printf '%s\n' "[oh-my-bash] Random theme '$OMB_THEME_RANDOM_SELECTED' ($_omb_init_file) loaded..."
fi
unset -v _omb_init_files _omb_init_file
