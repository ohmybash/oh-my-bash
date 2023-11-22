#!/usr/bin/env bash

# Bail out early if non-interactive
#
# Note: We cannot produce any error messages here because, in some systems,
# /etc/gdm3/Xsession sources ~/.profile and checks stderr.  If there is any
# stderr ourputs, it refuses to start the session.
case $- in
  *i*) ;;
    *) return;;
esac

if [ -z "${BASH_VERSION-}" ]; then
  printf '%s\n' 'oh-my-bash: This is not a Bash. Use OMB with Bash 3.2 or higher.' >&2
  return 1
fi
_omb_bash_version=$((BASH_VERSINFO[0] * 10000 + BASH_VERSINFO[1] * 100 + BASH_VERSINFO[2]))
if ((_omb_bash_version < 30200)); then
  printf '%s\n' "oh-my-bash: OMB does not support this version of Bash ($BASH_VERSION)" >&2
  printf '%s\n' "oh-my-bash: Use OMB with Bash 3.2 or higher" >&2
  return 1
fi

OMB_VERSINFO=(1 0 0 0 master noarch)
OMB_VERSION="${OMB_VERSINFO[0]}.${OMB_VERSINFO[1]}.${OMB_VERSINFO[2]}(${OMB_VERSINFO[3]})-${OMB_VERSINFO[4]} (${OMB_VERSINFO[5]})"
_omb_version=$((OMB_VERSINFO[0] * 10000 + OMB_VERSINFO[1] * 100 + OMB_VERSINFO[2]))

# Check for updates on initial load...
if [[ $DISABLE_AUTO_UPDATE != true ]]; then
  source "$OSH"/tools/check_for_upgrade.sh
fi

# Initializes Oh My Bash

# Set OSH_CUSTOM to the path where your custom config files
# and plugins exists, or else we will use the default custom/
if [[ ! ${OSH_CUSTOM-} ]]; then
  OSH_CUSTOM=$OSH/custom
  [[ -d $OSH_CUSTOM && -O $OSH_CUSTOM ]] ||
    OSH_CUSTOM=${XDG_DATA_HOME:-$HOME/.local/share}/oh-my-bash/custom
fi

# Set OSH_CACHE_DIR to the path where cache files should be created
# or else we will use the default cache/
if [[ ! ${OSH_CACHE_DIR-} ]]; then
  OSH_CACHE_DIR=$OSH/cache
  [[ -d $OSH_CACHE_DIR && -O $OSH_CACHE_DIR ]] ||
    OSH_CACHE_DIR=${XDG_STATE_HOME:-$HOME/.local/state}/oh-my-bash/cache
fi

_omb_module_loaded=
function _omb_module_require {
  local status=0
  local -a files=() modules=()
  while (($#)); do
    local type=lib name=$1; shift
    [[ $name == *:* ]] && type=${name%%:*} name=${name#*:}
    name=${name%.bash}
    name=${name%.sh}

    local module=$type:$name
    [[ ' '$_omb_module_loaded' ' == *" $module "* ]] && continue

    local -a locations=()
    case $type in
    lib)        locations=({"$OSH_CUSTOM","$OSH"}/lib/"$name".{bash,sh}) ;;
    plugin)     locations=({"$OSH_CUSTOM","$OSH"}/plugins/"$name"/"$name".plugin.{bash,sh}) ;;
    alias)      locations=({"$OSH_CUSTOM","$OSH"}/aliases/"$name".aliases.{bash,sh}) ;;
    completion) locations=({"$OSH_CUSTOM","$OSH"}/completions/"$name".completion.{bash,sh}) ;;
    theme)      locations=({"$OSH_CUSTOM"{,/themes},"$OSH"/themes}/"$name"/"$name".theme.{bash,sh}) ;;
    *)
      echo "oh-my-bash (module_require): unknown module type '$type'." >&2
      status=2
      continue ;;
    esac

    local path
    for path in "${locations[@]}"; do
      if [[ -f $path ]]; then
        files+=("$path")
        modules+=("$module")
        continue 2
      fi
    done

    echo "oh-my-bash (module_require): module '$type:$name' not found." >&2
    status=127
  done

  if ((status == 0)); then
    local i
    for i in "${!files[@]}"; do
      local path=${files[i]} module=${modules[i]}
      [[ ' '$_omb_module_loaded' ' == *" $module "* ]] && continue
      _omb_module_loaded="$_omb_module_loaded $module"
      source "$path" || status=$?
    done
  fi

  return "$status"
}

function _omb_module_require_lib        { _omb_module_require "${@/#/lib:}"; }
function _omb_module_require_plugin     { _omb_module_require "${@/#/plugin:}"; }
function _omb_module_require_alias      { _omb_module_require "${@/#/alias:}"; }
function _omb_module_require_completion { _omb_module_require "${@/#/completion:}"; }
function _omb_module_require_theme      { _omb_module_require "${@/#/theme:}"; }

# Load all of the config files in ~/.oh-my-bash/lib that end in .sh
# TIP: Add files you don't want in git to .gitignore
_omb_module_require_lib utils
_omb_util_glob_expand _omb_init_files '{"$OSH","$OSH_CUSTOM"}/lib/*.{bash,sh}'
_omb_init_files=("${_omb_init_files[@]##*/}")
_omb_init_files=("${_omb_init_files[@]%.bash}")
_omb_init_files=("${_omb_init_files[@]%.sh}")
_omb_module_require_lib "${_omb_init_files[@]}"
unset -v _omb_init_files

# Figure out the SHORT hostname
if [[ $OSTYPE = darwin* ]]; then
  # macOS's $HOST changes with dhcp, etc. Use ComputerName if possible.
  SHORT_HOST=$(scutil --get ComputerName 2>/dev/null) || SHORT_HOST=${HOST/.*}
else
  SHORT_HOST=${HOST/.*}
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

# Load the theme
if [[ $OSH_THEME == random ]]; then
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
    echo "[oh-my-bash] Random theme '$OMB_THEME_RANDOM_SELECTED' ($_omb_init_file) loaded..."
  fi
  unset -v _omb_init_files _omb_init_file
elif [[ $OSH_THEME ]]; then
  _omb_module_require_theme "$OSH_THEME"
fi

if [[ $PROMPT ]]; then
  export PS1='\['$PROMPT'\]'
fi

if ! _omb_util_command_exists '__git_ps1'; then
  source "$OSH/tools/git-prompt.sh"
fi

# Adding Support for other OSes
if [[ -s /usr/bin/gloobus-preview ]]; then
  PREVIEW="gloobus-preview"
elif [[ -s /Applications/Preview.app ]]; then
  PREVIEW="/Applications/Preview.app"
else
  PREVIEW="less"
fi
