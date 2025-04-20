#! bash oh-my-bash.module

# This theme loads another randomly-chosen theme.

_omb_util_glob_expand _omb_init_files '"$OSH"/themes/*/*.theme.sh'

# Remove ignored themes from the list
for _omb_init_theme in random "${OMB_THEME_RANDOM_IGNORED[@]}"; do
  for _omb_init_index in "${!_omb_init_files[@]}"; do
    [[ ${_omb_init_files[_omb_init_index]} == */"$_omb_init_theme"/* ]] &&
      unset -v '_omb_init_files[_omb_init_index]'
  done
  unset -v _omb_init_index
done
unset -v _omb_init_theme
_omb_init_files=("${_omb_init_files[@]}")

if ((${#_omb_init_files[@]})); then
  _omb_init_file=${_omb_init_files[RANDOM%${#_omb_init_files[@]}]}
  source "$_omb_init_file"
  OMB_THEME_RANDOM_SELECTED=${_omb_init_file##*/}
  OMB_THEME_RANDOM_SELECTED=${OMB_THEME_RANDOM_SELECTED%.theme.bash}
  OMB_THEME_RANDOM_SELECTED=${OMB_THEME_RANDOM_SELECTED%.theme.sh}
  printf '%s\n' "[oh-my-bash] Random theme '$OMB_THEME_RANDOM_SELECTED' ($_omb_init_file) loaded..."
fi
unset -v _omb_init_files _omb_init_file
