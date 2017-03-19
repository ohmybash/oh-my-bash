# Check for updates on initial load...
if [ "$DISABLE_AUTO_UPDATE" != "true" ]; then
  env OSH=$OSH DISABLE_UPDATE_PROMPT=$DISABLE_UPDATE_PROMPT sh -f $OSH/tools/check_for_upgrade.sh
fi

# Initializes Oh My Bash

# add a function path
fpath=($OSH/functions $OSH/completions $fpath)

# Set OSH_CUSTOM to the path where your custom config files
# and plugins exists, or else we will use the default custom/
if [[ -z "$OSH_CUSTOM" ]]; then
    OSH_CUSTOM="$OSH/custom"
fi

# Set OSH_CACHE_DIR to the path where cache files should be created
# or else we will use the default cache/
if [[ -z "$OSH_CACHE_DIR" ]]; then
  OSH_CACHE_DIR="$OSH/cache"
fi


# Load all of the config files in ~/.oh-my-bash/lib that end in .sh
# TIP: Add files you don't want in git to .gitignore
for config_file in $OSH/lib/*.sh; do
  custom_config_file="${OSH_CUSTOM}/lib/${config_file:t}"
  [ -f "${custom_config_file}" ] && config_file=${custom_config_file}
  source $config_file
done


is_plugin() {
  local base_dir=$1
  local name=$2
  test -f $base_dir/plugins/$name/$name.plugin.sh \
    || test -f $base_dir/plugins/$name/_$name
}
# Add all defined plugins to fpath. This must be done
# before running compinit.
for plugin in $plugins; do
  if is_plugin $OSH_CUSTOM $plugin; then
    fpath=($OSH_CUSTOM/plugins/$plugin $fpath)
  elif is_plugin $OSH $plugin; then
    fpath=($OSH/plugins/$plugin $fpath)
  fi
done

# Figure out the SHORT hostname
if [[ "$OSTYPE" = darwin* ]]; then
  # macOS's $HOST changes with dhcp, etc. Use ComputerName if possible.
  SHORT_HOST=$(scutil --get ComputerName 2>/dev/null) || SHORT_HOST=${HOST/.*/}
else
  SHORT_HOST=${HOST/.*/}
fi

# Load all of the plugins that were defined in ~/.bashrc
for plugin in $plugins; do
  if [ -f $OSH_CUSTOM/plugins/$plugin/$plugin.plugin.sh ]; then
    source $OSH_CUSTOM/plugins/$plugin/$plugin.plugin.sh
  elif [ -f $OSH/plugins/$plugin/$plugin.plugin.sh ]; then
    source $OSH/plugins/$plugin/$plugin.plugin.sh
  fi
done

# Load all of your custom configurations from custom/
for config_file in $OSH_CUSTOM/*.sh; do
  if [ -f config_file ]; then
    source $config_file
  fi
done
unset config_file

# Load the theme
if [ "$OSH_THEME" = "random" ]; then
  themes=($OSH/themes/*theme.sh)
  N=${#themes[@]}
  ((N=(RANDOM%N)+1))
  RANDOM_THEME=${themes[$N]}
  source "$RANDOM_THEME"
  echo "[oh-my-bash] Random theme '$RANDOM_THEME' loaded..."
else
  if [ ! "$OSH_THEME" = ""  ]; then
    if [ -f "$OSH_CUSTOM/$OSH_THEME.theme.sh" ]; then
      source "$OSH_CUSTOM/$OSH_THEME.theme.sh"
    elif [ -f "$OSH_CUSTOM/themes/$OSH_THEME.theme.sh" ]; then
      source "$OSH_CUSTOM/themes/$OSH_THEME.theme.sh"
    else
      source "$OSH/themes/$OSH_THEME.theme.sh"
    fi
  fi
fi
