#! bash oh-my-bash.module

# Check if starship is installed
if _omb_util_command_exists starship; then
    eval "$(starship init bash)"
else
    echo '[oh-my-bash] starship not found, please install it from https://github.com/starship/starship'
fi
