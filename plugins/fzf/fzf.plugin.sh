#! bash oh-my-bash.module

# Check if fzf is installed
if _omb_util_command_exists fzf; then
    [ -f ~/.fzf.bash ] && source ~/.fzf.bash
else
    _omb_util_print '[oh-my-bash] fzf not found, please install it from https://github.com/junegunn/fzf' >&2
fi
