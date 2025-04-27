#! bash oh-my-bash.module

# Check if jump is installed
if _omb_util_command_exists jump; then
    eval "$(jump shell bash)"
else
    echo '[oh-my-bash] jump not found, please install it from https://github.com/gsamokovarov/jump'
fi
