#!/usr/bin/env bash

# Bail out early if non-interactive
if [[ $- != *i* ]]; then
  printf 'oh-my-bash: Shell is not interactive.\n' >&2
  return 1
fi

# Check for updates on initial load...
if [ "$DISABLE_AUTO_UPDATE" != "true" ]; then
  env OSH="$OSH" DISABLE_UPDATE_PROMPT="$DISABLE_UPDATE_PROMPT" bash -f "$OSH"/tools/check_for_upgrade.sh
fi

# Initializes Oh My Bash

# Set OSH_CUSTOM to the path where your custom config files
# and plugins exists, or else we will use the default custom/
: "${OSH_CUSTOM:=$OSH/custom}"

# Set OSH_CACHE_DIR to the path where cache files should be created
# or else we will use the default cache/
: "${OSH_CACHE_DIR:=$OSH/cache}"

_omb_module_loaded=
_omb_module_require() {
  local status=0
  local -a files=()
  while (($#)); do
    local type=lib name=$1; shift
    [[ $name == *:* ]] && type=${name%%:*} name=${name#*:}
    name=${name%.bash}
    name=${name%.sh}
    [[ ' '$_omb_module_loaded' ' == *" $type:$name "* ]] && continue
    _omb_module_loaded="$_omb_module_loaded $type:$name"

    local -a locations=()
    case $type in
    lib)        locations=({"$OSH_CUSTOM","$OSH"}/lib/"$name".{bash,sh}) ;;
    plugin)     locations=({"$OSH_CUSTOM","$OSH"}/plugins/"$name"/"$name".plugin.{bash,sh}) ;;
    alias)      locations=({"$OSH_CUSTOM","$OSH"}/aliases/"$name".aliases.{bash,sh}) ;;
    completion) locations=({"$OSH_CUSTOM","$OSH"}/completions/"$name".completion.{bash,sh}) ;;
    theme)      locations=({"$OSH_CUSTOM"{,/themes},"$OSH"/themes}/"$name"/"$name".theme.{bash,sh}) ;;
    *)
      echo "oh-my-bash (module_require): unknown package type '$type'." >&2
      status=2
      continue ;;
    esac

    local path
    for path in "${locations[@]}"; do
      if [[ -f $path ]]; then
        files+=("$path")
        continue 2
      fi
    done

    echo "oh-my-bash (module_require): package '$type:$name' not found." >&2
    status=127
  done

  if ((status==0)); then
    local path
    for path in "${files[@]}"; do
      source "$path" || status=$?
    done
  fi

  return "$status"
}

_omb_module_require_lib()        { _omb_module_require "${@/#/lib:}"; }
_omb_module_require_plugin()     { _omb_module_require "${@/#/plugin:}"; }
_omb_module_require_alias()      { _omb_module_require "${@/#/alias:}"; }
_omb_module_require_completion() { _omb_module_require "${@/#/completion:}"; }
_omb_module_require_theme()      { _omb_module_require "${@/#/theme:}"; }

# Load all of the config files in ~/.oh-my-bash/lib that end in .sh
# TIP: Add files you don't want in git to .gitignore
_omb_module_require_lib utils
_omb_module_require_lib omb-deprecate
_omb_util_glob_expand _omb_init_files '{"$OSH","$OSH_CUSTOM"}/lib/*.sh'
_omb_init_files=("${_omb_init_files[@]##*/}")
_omb_init_files=("${_omb_init_files[@]%.sh}")
_omb_module_require_lib "${_omb_init_files[@]}"
unset -v _omb_init_files

# Figure out the SHORT hostname
if [[ "$OSTYPE" = darwin* ]]; then
  # macOS's $HOST changes with dhcp, etc. Use ComputerName if possible.
  SHORT_HOST=$(scutil --get ComputerName 2>/dev/null) || SHORT_HOST=${HOST/.*/}
else
  SHORT_HOST=${HOST/.*/}
fi

# Load all of the plugins that were defined in ~/.bashrc
_omb_module_require_plugin "${plugins[@]}"

# Load all of the aliases that were defined in ~/.bashrc
_omb_module_require_alias "${aliases[@]}"

# Load all of the completions that were defined in ~/.bashrc
_omb_module_require_completion "${completions[@]}"

# Load all of your custom configurations from custom/
_omb_util_glob_expand _omb_init_files '"$OSH_CUSTOM"/*.{sh,bash}'
for _omb_init_file in "${_omb_init_files[@]}"; do
  [[ -f $_omb_init_file ]] &&
    source "$_omb_init_file"
done
unset -v _omb_init_files _omb_init_file

# Load colors first so they can be use in base theme
source "${OSH}/themes/colours.theme.sh"
source "${OSH}/themes/base.theme.sh"

# Load the theme
if [[ $OSH_THEME == random ]]; then
  _omb_util_glob_expand _omb_init_files '"$OSH"/themes/*/*.theme.sh'
  if ((${#_omb_init_files[@]})); then
    _omb_init_file=${_omb_init_files[RANDOM%${#_omb_init_files[@]}]}
    source "$_omb_init_file"
    echo "[oh-my-bash] Random theme '$_omb_init_file' loaded..."
  fi
  unset -v _omb_init_files _omb_init_file
elif [[ $OSH_THEME ]]; then
  _omb_module_require_theme "$OSH_THEME"
fi

if [[ $PROMPT ]]; then
  export PS1="\["$PROMPT"\]"
fi

if ! _omb_util_command_exists '__git_ps1' ; then
  source "$OSH/tools/git-prompt.sh"
fi

# Adding Support for other OSes
[ -s /usr/bin/gloobus-preview ] && PREVIEW="gloobus-preview" ||
[ -s /Applications/Preview.app ] && PREVIEW="/Applications/Preview.app" || PREVIEW="less"
