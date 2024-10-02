#! bash oh-my-bash.module

# Load the given theme, or a random one if none is provided.
function theme() {
  local desired_theme="$1"

  # Random
  if [[ -z "$desired_theme" ]]; then
    local theme_files
    _omb_util_glob_expand theme_files '"$OSH"/themes/*/*.theme.sh'
    theme_files=("${theme_files[@]}")

    if ((${#theme_files[@]})); then
      local random_theme=${theme_files[RANDOM%${#theme_files[@]}]}
      desired_theme=$(basename $(dirname "$random_theme"))
      echo "${_omb_term_reset}theme ${_omb_term_bold}${desired_theme}$_omb_term_reset"
    else
      echo "No themes found."
      return 1
    fi
  fi

  _omb_module_require_theme "$desired_theme"
}

# List all available themes
function lstheme() {
  local theme_files
  _omb_util_glob_expand theme_files '"$OSH"/themes/*/*.theme.sh'
  for i in "${theme_files[@]}"; do
    echo $(basename $(dirname "$i"))
  done
}
